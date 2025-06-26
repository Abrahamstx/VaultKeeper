;; VaultKeeper - Decentralized Escrow Service
;; A smart contract for secure peer-to-peer transactions with escrow functionality

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-ESCROW-NOT-FOUND (err u404))
(define-constant ERR-INVALID-AMOUNT (err u400))
(define-constant ERR-ESCROW-ALREADY-RELEASED (err u409))
(define-constant ERR-ESCROW-ALREADY-REFUNDED (err u410))
(define-constant ERR-INSUFFICIENT-FUNDS (err u402))
(define-constant ERR-INVALID-SELLER (err u403))

;; Escrow statuses
(define-constant STATUS-ACTIVE u1)
(define-constant STATUS-RELEASED u2)
(define-constant STATUS-REFUNDED u3)

;; Data structures
(define-map escrows
  { escrow-id: uint }
  {
    buyer: principal,
    seller: principal,
    amount: uint,
    status: uint,
    created-at: uint
  }
)

;; Contract state
(define-data-var next-escrow-id uint u1)
(define-data-var contract-owner principal tx-sender)

;; Read-only functions
(define-read-only (get-escrow (escrow-id uint))
  (map-get? escrows { escrow-id: escrow-id })
)

(define-read-only (get-next-escrow-id)
  (var-get next-escrow-id)
)

(define-read-only (get-contract-owner)
  (var-get contract-owner)
)

;; Public functions
(define-public (create-escrow (seller principal) (amount uint))
  (let
    (
      (escrow-id (var-get next-escrow-id))
      (current-block stacks-block-height)
    )
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (asserts! (not (is-eq seller tx-sender)) ERR-INVALID-SELLER)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set escrows
      { escrow-id: escrow-id }
      {
        buyer: tx-sender,
        seller: seller,
        amount: amount,
        status: STATUS-ACTIVE,
        created-at: current-block
      }
    )
    (var-set next-escrow-id (+ escrow-id u1))
    (ok escrow-id)
  )
)

(define-public (release-escrow (escrow-id uint))
  (let
    (
      (escrow-data (unwrap! (get-escrow escrow-id) ERR-ESCROW-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender (get buyer escrow-data)) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status escrow-data) STATUS-ACTIVE) ERR-ESCROW-ALREADY-RELEASED)
    (try! (as-contract (stx-transfer? (get amount escrow-data) tx-sender (get seller escrow-data))))
    (map-set escrows
      { escrow-id: escrow-id }
      (merge escrow-data { status: STATUS-RELEASED })
    )
    (ok true)
  )
)

(define-public (refund-escrow (escrow-id uint))
  (let
    (
      (escrow-data (unwrap! (get-escrow escrow-id) ERR-ESCROW-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender (get seller escrow-data)) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status escrow-data) STATUS-ACTIVE) ERR-ESCROW-ALREADY-REFUNDED)
    (try! (as-contract (stx-transfer? (get amount escrow-data) tx-sender (get buyer escrow-data))))
    (map-set escrows
      { escrow-id: escrow-id }
      (merge escrow-data { status: STATUS-REFUNDED })
    )
    (ok true)
  )
)