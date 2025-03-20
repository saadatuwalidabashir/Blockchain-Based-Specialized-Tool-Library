;; Tool Inventory Contract
;; Records details of available specialized equipment

;; Define data structures
(define-map tools
  { tool-id: uint }
  {
    name: (string-utf8 100),
    description: (string-utf8 500),
    category: (string-utf8 50),
    available: bool,
    owner: principal,
    condition: (string-utf8 50)
  }
)

(define-data-var next-tool-id uint u1)

;; Read-only functions
(define-read-only (get-tool (tool-id uint))
  (map-get? tools { tool-id: tool-id })
)

(define-read-only (get-tool-count)
  (var-get next-tool-id)
)

;; Public functions
(define-public (add-tool (name (string-utf8 100)) (description (string-utf8 500)) (category (string-utf8 50)) (condition (string-utf8 50)))
  (let
    (
      (tool-id (var-get next-tool-id))
    )
    (map-set tools
      { tool-id: tool-id }
      {
        name: name,
        description: description,
        category: category,
        available: true,
        owner: tx-sender,
        condition: condition
      }
    )
    (var-set next-tool-id (+ tool-id u1))
    (ok tool-id)
  )
)

(define-public (update-tool-availability (tool-id uint) (available bool))
  (let
    (
      (tool (unwrap! (map-get? tools { tool-id: tool-id }) (err u404)))
    )
    (asserts! (is-eq tx-sender (get owner tool)) (err u403))
    (map-set tools
      { tool-id: tool-id }
      (merge tool { available: available })
    )
    (ok true)
  )
)

(define-public (update-tool-condition (tool-id uint) (condition (string-utf8 50)))
  (let
    (
      (tool (unwrap! (map-get? tools { tool-id: tool-id }) (err u404)))
    )
    (asserts! (is-eq tx-sender (get owner tool)) (err u403))
    (map-set tools
      { tool-id: tool-id }
      (merge tool { condition: condition })
    )
    (ok true)
  )
)
