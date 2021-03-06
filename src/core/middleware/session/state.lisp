#|
  This file is a part of Clack package.
  URL: http://github.com/fukamachi/clack
  Copyright (c) 2011 Eitaro Fukamachi <e.arrows@gmail.com>

  Clack is freely distributable under the LLGPL License.
|#

(in-package :cl-user)
(defpackage clack.session.state
  (:use :cl)
  (:import-from :clack.util
                :generate-random-id)
  (:import-from :cl-ppcre
                :scan)
  (:import-from :alexandria
                :when-let)
  (:export :session-key
           :sid-generator
           :sid-validator))
(in-package :clack.session.state)

(cl-syntax:use-syntax :annot)

@export
(defclass <clack-session-state> ()
     ((session-key :type keyword
                   :initarg :session-key
                   :initform :clack.session
                   :accessor session-key)
      (sid-generator :type function
                     :initarg :sid-generator
                     :initform
                     #'(lambda (&rest args)
                         @ignore args
                         (clack.util:generate-random-id))
                     :accessor sid-generator)
      (sid-validator :type function
                     :initarg :sid-validator
                     :initform
                     #'(lambda (sid)
                         (not (null (ppcre:scan "\\A[0-9a-f]{40}\\Z" sid))))
                     :accessor sid-validator)))

@export
(defgeneric expire (state id res &optional options)
  (:method ((this <clack-session-state>)
            id res &optional options)
    @ignore (this id res options)))

@export
(defgeneric session-id (state env)
  (:method ((this <clack-session-state>) env)
    (getf env (session-key this))))

@export
(defgeneric valid-sid-p (state id)
  (:method ((this <clack-session-state>) id)
    (funcall (sid-validator this) id)))

@export
(defgeneric extract-id (state env)
  (:method ((this <clack-session-state>) env)
    (when-let (sid (session-id this env))
      (and (valid-sid-p this sid)
           sid))))

@export
(defgeneric generate-id (state &rest args)
  (:method ((this <clack-session-state>) &rest args)
    (apply (sid-generator this) args)))

@export
(defgeneric finalize (state id res options)
  (:method ((this <clack-session-state>) id res options)
    @ignore (this id options)
    res))

(doc:start)

@doc:NAME "
Clack.Session.State - Basic parameter-based session state.
"

@doc:DESCRIPTION "
Clack.Session.State maintains session state by passing the session through the request params. Usually you wouldn't use this because this cannot keep session through each HTTP request. This is just for creating new session state manager.
"

@doc:AUTHOR "
Eitaro Fukamachi (e.arrows@gmail.com)
"

@doc:SEE "
* Clack.Middleware.Session
"
