#lang sicp
; environment model >:)

; variables are no longer simply names for expressions
; so what still works?
; let's say the only way to create a binding is via a lambda!
; via bound and free variables (scope :))

; environment is a chain of frames
; frames = set of bindings
; environments are compared via their bindings

; Evaluating a combination:
; - Evaluate the subexpressions of the combination
; - Apply the value of the operator subexpression to the values of the operand subexpression
; Evaluating a procedure definition:
; - Create a procedure object by evaluating a lambda-expression relative to a given environment
; Evaluating a procedure application
; -  Create a new environment containing a frame that binds the parameters to the arguments, and then evaluate the body of the procedure in the new environment.

