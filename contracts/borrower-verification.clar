;; Borrower Verification Contract
;; Manages user qualifications for specific tools

;; Define data structures
(define-map qualifications
  { user: principal, category: (string-utf8 50) }
  {
    verified: bool,
    level: uint,
    verifier: principal,
    expiration: uint
  }
)

;; Define constants
(define-constant ADMIN tx-sender)

;; Read-only functions
(define-read-only (get-qualification (user principal) (category (string-utf8 50)))
  (map-get? qualifications { user: user, category: category })
)

(define-read-only (is-qualified (user principal) (category (string-utf8 50)) (required-level uint))
  (let
    (
      (qual (map-get? qualifications { user: user, category: category }))
    )
    (if (is-some qual)
      (let
        (
          (qualification (unwrap-panic qual))
          (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
        )
        (and
          (get verified qualification)
          (>= (get level qualification) required-level)
          (< current-time (get expiration qualification))
        )
      )
      false
    )
  )
)

;; Public functions
(define-public (add-qualification (user principal) (category (string-utf8 50)) (level uint) (expiration uint))
  (begin
    (asserts! (or (is-eq tx-sender ADMIN) (is-admin tx-sender)) (err u403))
    (map-set qualifications
      { user: user, category: category }
      {
        verified: true,
        level: level,
        verifier: tx-sender,
        expiration: expiration
      }
    )
    (ok true)
  )
)

(define-public (revoke-qualification (user principal) (category (string-utf8 50)))
  (begin
    (asserts! (or (is-eq tx-sender ADMIN) (is-admin tx-sender)) (err u403))
    (map-delete qualifications { user: user, category: category })
    (ok true)
  )
)

;; Private functions
(define-private (is-admin (user principal))
  ;; In a real implementation, this would check against a list of admins
  false
)
