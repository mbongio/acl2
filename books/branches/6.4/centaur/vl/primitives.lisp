; VL Verilog Toolkit
; Copyright (C) 2008-2011 Centaur Technology
;
; Contact:
;   Centaur Technology Formal Verification Group
;   7600-C N. Capital of Texas Highway, Suite 300, Austin, TX 78731, USA.
;   http://www.centtech.com/
;
; This program is free software; you can redistribute it and/or modify it under
; the terms of the GNU General Public License as published by the Free Software
; Foundation; either version 2 of the License, or (at your option) any later
; version.  This program is distributed in the hope that it will be useful but
; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
; more details.  You should have received a copy of the GNU General Public
; License along with this program; if not, write to the Free Software
; Foundation, Inc., 51 Franklin Street, Suite 500, Boston, MA 02110-1335, USA.
;
; Original author: Jared Davis <jared@centtech.com>

(in-package "VL")
(include-book "mlib/expr-building")
(include-book "../esim/esim-primitives")
(local (include-book "mlib/stmt-tools"))


(defxdoc primitives
  :parents (vl)
  :short "The primitive modules targetted by VL."

  :long "<p>The modules here can sort of be thought of as the target language
for VL's simplification scheme.  That is, our usual sequence of @(see
transforms) tries to convert rich Verilog modules that include expressions,
gates, parameters, etc., into simple, hierarchical modules that do nothing more
than instantiate other modules, with these primitive modules at the tips.</p>

<p><b>BOZO</b> This set of primitives modules could be simplified, for instance
we could rewrite all of the basic gate modules into @('nand') or some other
basic form.  We haven't done this yet, under the (probably misguided) theory
that having a richer set of primitives might somehow be more efficient for our
symbolic simulator.</p>")


(defsection vl-primitive-mkport

; This is similar to vl-occform-mkport, but our primitives are all one-bit
; things so we leave out the ranges to make them prettier.

  (defund vl-primitive-mkport (name dir)
    "Returns (MV EXPR PORT PORTDECL NETDECL)"
    (declare (xargs :guard (and (stringp name)
                                (vl-direction-p dir))))
    (b* ((name     (hons-copy name))
         (expr     (vl-idexpr name 1 :vl-unsigned))
         (port     (make-vl-port     :name name :expr expr     :loc *vl-fakeloc*))
         (portdecl (make-vl-portdecl :name name :dir  dir      :loc *vl-fakeloc*))
         (netdecl  (make-vl-netdecl  :name name :type :vl-wire :loc *vl-fakeloc*)))
      (mv expr port portdecl netdecl)))

  (local (in-theory (enable vl-primitive-mkport)))

  (defthm vl-primitive-mkport-basics
    (implies (and (force (stringp name))
                  (force (vl-direction-p dir)))
             (let ((ret (vl-primitive-mkport name dir)))
               (and (vl-expr-p        (mv-nth 0 ret))
                    (vl-port-p        (mv-nth 1 ret))
                    (vl-portdecl-p    (mv-nth 2 ret))
                    (vl-netdecl-p     (mv-nth 3 ret)))))))


(defsection vl-primitive-mkwire

; This is similar to vl-occform-mkwire, but our primitives are all one-bit
; things so we leave out the ranges to make them prettier.

  (defund vl-primitive-mkwire (name)
    "Returns (MV EXPR NETDECL)"
    (declare (xargs :guard (stringp name)))
    (b* ((name     (hons-copy name))
         (expr     (vl-idexpr name 1 :vl-unsigned))
         (netdecl  (make-vl-netdecl :name name :type :vl-wire :loc *vl-fakeloc*)))
      (mv expr netdecl)))

  (local (in-theory (enable vl-primitive-mkwire)))

  (defthm vl-primitive-mkwire-basics
    (implies (and (force (stringp name))
                  (force (posp width)))
             (let ((ret (vl-primitive-mkwire name)))
               (and (vl-expr-p        (mv-nth 0 ret))
                    (vl-netdecl-p     (mv-nth 1 ret)))))))


(defxdoc *vl-1-bit-t*
  :parents (primitives)
  :short "Primitive 1 (true) generator."
  :long "<p>The Verilog definition of this module is:</p>

@({
module VL_1_BIT_T (out) ;
  output out;
  assign out = 1'b1;
endmodule
})

<p>VL takes this as a primitive.  BOZO this module is currently unused but
we are going to start using it soon.</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-t*).</p>")

(defconsts *vl-1-bit-t*
  (b* ((name "VL_1_BIT_T")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       (out-assign (make-vl-assign :lvalue out-expr :expr |*sized-1'b1*| :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port)
                           :portdecls (list out-portdecl)
                           :netdecls  (list out-netdecl)
                           :assigns   (list out-assign)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-t*)))


(defxdoc *vl-1-bit-f*
  :parents (primitives)
  :short "Primitive 0 (false) generator."
  :long "<p>The Verilog definition of this module is:</p>

@({
module VL_1_BIT_F (out) ;
  output out;
  assign out = 1'b0;
endmodule
})

<p>VL takes this as a primitive.  BOZO this module is currently unused but
we are going to start using it soon.</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-f*).</p>")

(defconsts *vl-1-bit-f*
  (b* ((name "VL_1_BIT_F")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       (out-assign (make-vl-assign :lvalue out-expr :expr |*sized-1'b0*| :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port)
                           :portdecls (list out-portdecl)
                           :netdecls  (list out-netdecl)
                           :assigns   (list out-assign)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-f*)))


(defxdoc *vl-1-bit-x*
  :parents (primitives)
  :short "Primitive X (unknown) generator."
  :long "<p>The Verilog definition of this module is:</p>

@({
module VL_1_BIT_X (out) ;
  output out;
  assign out = 1'bx;
endmodule
})

<p>VL takes this as a primitive.  This module is mainly used by @(see
weirdint-elim) to eliminate explicit X values from literals.</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-x*).</p>")

(defconsts *vl-1-bit-x*
  (b* ((name "VL_1_BIT_X")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       (out-assign (make-vl-assign :lvalue out-expr :expr |*sized-1'bx*| :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port)
                           :portdecls (list out-portdecl)
                           :netdecls  (list out-netdecl)
                           :assigns   (list out-assign)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-x*)))


(defxdoc *vl-1-bit-z*
  :parents (primitives)
  :short "Primitive Z (floating) generator."
  :long "<p>The Verilog definition of this module is:</p>

@({
module VL_1_BIT_Z (out) ;
  output out;
  assign out = 1'bz;
endmodule
})

<p>VL takes this as a primitive.  This module is mainly used by @(see
weirdint-elim) to eliminate explicit Z values from literals.</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-z*).</p>")

(defconsts *vl-1-bit-z*
  (b* ((name "VL_1_BIT_Z")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       (out-assign (make-vl-assign :lvalue out-expr :expr |*sized-1'bz*| :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port)
                           :portdecls (list out-portdecl)
                           :netdecls  (list out-netdecl)
                           :assigns   (list out-assign)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-z*)))


(defxdoc *vl-1-bit-power*
  :parents (primitives)
  :short "Primitive power source or @('supply1') signal."
  :long "<p>The Verilog definition of this module is:</p>

@({
module VL_1_BIT_POWER (out) ;
  output out;
  supply1 out;
endmodule
})

<p>VL takes this as a primitive.  This module is typically introduced by the
@(see elim-supplies) transform to replace @('supply1') wires.</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-t*).  This is
also how esim treats @(see *vl-1-bit-t*), i.e., in esim there is no difference
between a power source and an ordinary constant @('1'b1') value.  We have a
separate primitive mainly so that other backends with more transistor-level
support can implement them in other ways.</p>")

(defconsts *vl-1-bit-power*
  (b* ((name "VL_1_BIT_POWER")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv ?out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       (out-netdecl (change-vl-netdecl out-netdecl :type :vl-supply1)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port)
                           :portdecls (list out-portdecl)
                           :netdecls  (list out-netdecl)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-t*)))


(defxdoc *vl-1-bit-ground*
  :parents (primitives)
  :short "Primitive ground or @('supply0') signal."
  :long "<p>The Verilog definition of this module is:</p>

@({
module VL_1_BIT_GROUND (out) ;
  output out;
  supply0 out;
endmodule
})

<p>VL takes this as a primitive.  This module is typically introduced by the
@(see elim-supplies) transform to replace @('supply0') wires.</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-f*).  This is
also how esim treats @(see *vl-1-bit-f*), i.e., in esim there is no difference
between ground and an ordinary constant @('1'b0') value.  We have a separate
primitive mainly so that other backends with more transistor-level support can
implement them in other ways.</p>")

(defconsts *vl-1-bit-ground*
  (b* ((name "VL_1_BIT_GROUND")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv ?out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       (out-netdecl (change-vl-netdecl out-netdecl :type :vl-supply0)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port)
                           :portdecls (list out-portdecl)
                           :netdecls  (list out-netdecl)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-f*)))


(defxdoc *vl-1-bit-assign*
  :parents (primitives)
  :short "Primitive assignment module."
  :long "<p>The Verilog definition of this module is:</p>

@({
module VL_1_BIT_ASSIGN (out, in) ;
  output out;
  input in;
  assign out = in;
endmodule
})

<p>VL takes this as a primitive.  This module is also the basis for wider
assignment modules; see @(see vl-make-n-bit-assign).</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-id*).</p>

<p>Something subtle is that there is probably no way to implement
@('VL_1_BIT_ASSIGN') in hardware.  One obvious approach would be to use a
buffer, but then @('out') would be X when @('in') is Z.  Another approach would
be to just wire together out and in, but then other assignments to @('out')
would also affect @('in'), and in Verilog this isn't the case.</p>

<p>Originally our @(see occform) transformation tried to use buffers for
assignments since this seemed to be more conservative.  But these extra buffers
seemed to often be inappropriate, especially when dealing with lower level
modules that involve transistors.</p>")

(defconsts *vl-1-bit-assign*
  (b* ((name "VL_1_BIT_ASSIGN")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv in-expr  in-port  in-portdecl  in-netdecl)  (vl-primitive-mkport "in"  :vl-input))
       (assign (make-vl-assign :lvalue out-expr :expr in-expr :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     in-port)
                           :portdecls (list out-portdecl in-portdecl)
                           :netdecls  (list out-netdecl  in-netdecl)
                           :assigns   (list assign)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-id*)))


(defxdoc *vl-1-bit-delay-1*
  :parents (primitives)
  :short "Primitive assignment with delay."
  :long "<p>The Verilog definition of this module is:</p>

@({
module VL_1_BIT_DELAY_1 (out, in) ;
  output out;
  input in;
  assign #1 out = in;
endmodule
})

<p>VL takes this as a primitive.  It is used by our @(see delayredux) transform
to separate delays from assignment statements.</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-del*), but note
that esim really has no notion of delays and this ends up being equivalent to
an ordinary @(see *vl-1-bit-assign*).</p>")

(defconsts *vl-1-bit-delay-1*
  (b* ((name "VL_1_BIT_DELAY_1")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv in-expr  in-port  in-portdecl  in-netdecl)  (vl-primitive-mkport "in"  :vl-input))
       (one    (vl-make-index 1))
       (delay  (make-vl-gatedelay :rise one :fall one :high one))
       (assign (make-vl-assign :lvalue out-expr :expr in-expr :delay delay :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     in-port)
                           :portdecls (list out-portdecl in-portdecl)
                           :netdecls  (list out-netdecl  in-netdecl)
                           :assigns   (list assign)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-del*)))


(defxdoc *vl-1-bit-buf*
  :parents (primitives)
  :short "Primitive buffer module."
  :long "<p>The Verilog definition of this module is:</p>

@({
module VL_1_BIT_BUF (out, in) ;
  output out;
  input in;
  buf gate (out, in);
endmodule
})

<p>VL takes this as a primitive.  We use this in place of @('buf') gates, but
probably not for much else since ordinary assignments are handled with @(see
*vl-1-bit-assign*), instead.</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-buf*).</p>")

(defconsts *vl-1-bit-buf*
  (b* ((name "VL_1_BIT_BUF")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv in-expr  in-port  in-portdecl  in-netdecl)  (vl-primitive-mkport "in"  :vl-input))
       (gate (make-vl-gateinst :type :vl-buf
                               :name "gate"
                               :args (list (make-vl-plainarg :expr out-expr :dir :vl-output)
                                           (make-vl-plainarg :expr in-expr  :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     in-port)
                           :portdecls (list out-portdecl in-portdecl)
                           :netdecls  (list out-netdecl  in-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-buf*)))


(defxdoc *vl-1-bit-not*
  :parents (primitives)
  :short "Primitive not-gate module."
  :long "<p>The Verilog definition of this module is:</p>

@({
module VL_1_BIT_NOT (out, in) ;
  output out;
  input in;
  not gate (out, in);
endmodule
})

<p>VL takes this as a primitive.  We use this in place of @('not') gates and
@('~') operators, and also in many modules we generate for other operators like
@('+').</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-not*).</p>")

(defconsts *vl-1-bit-not*
  (b* ((name "VL_1_BIT_NOT")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv in-expr  in-port  in-portdecl  in-netdecl)  (vl-primitive-mkport "in"  :vl-input))
       (gate (make-vl-gateinst :type :vl-not
                               :name "gate"
                               :args (list (make-vl-plainarg :expr out-expr :dir :vl-output)
                                           (make-vl-plainarg :expr in-expr  :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port in-port)
                           :portdecls (list out-portdecl in-portdecl)
                           :netdecls  (list out-netdecl in-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-not*)))


(defxdoc *vl-1-bit-and*
  :parents (primitives)
  :short "Primitive and-gate module."
  :long "<p>The Verilog definition of this module is:</p>

@({
module VL_1_BIT_AND (out, a, b) ;
  output out;
  input a;
  input b;
  and gate (out, a, b);
endmodule
})

<p>VL takes this as a primitive.  We use this in place of @('and') gates and
@('&') operators, and also in many modules we generate for other operators like
@('+').</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-and*)</p>")

(defconsts *vl-1-bit-and*
  (b* ((name "VL_1_BIT_AND")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv a-expr   a-port   a-portdecl   a-netdecl)   (vl-primitive-mkport "a"   :vl-input))
       ((mv b-expr   b-port   b-portdecl   b-netdecl)   (vl-primitive-mkport "b"   :vl-input))
       (gate (make-vl-gateinst :type :vl-and
                               :name "gate"
                               :args (list (make-vl-plainarg :expr out-expr :dir :vl-output)
                                           (make-vl-plainarg :expr a-expr   :dir :vl-input)
                                           (make-vl-plainarg :expr b-expr   :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     a-port     b-port)
                           :portdecls (list out-portdecl a-portdecl b-portdecl)
                           :netdecls  (list out-netdecl  a-netdecl  b-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-and*)))


(defxdoc *vl-1-bit-or*
  :parents (primitives)
  :short "Primitive or-gate module."
  :long "<p>The Verilog definition of this module is:</p>

@({
module VL_1_BIT_OR (out, a, b) ;
  output out;
  input a;
  input b;
  or gate (out, a, b);
endmodule
})

<p>VL takes this as a primitive.  We use this in place of @('or') gates and
@('|') operators, and also in many modules we generate for other operators like
@('+').</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-or*)</p>")

(defconsts *vl-1-bit-or*
  (b* ((name "VL_1_BIT_OR")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv a-expr   a-port   a-portdecl   a-netdecl)   (vl-primitive-mkport "a"   :vl-input))
       ((mv b-expr   b-port   b-portdecl   b-netdecl)   (vl-primitive-mkport "b"   :vl-input))
       (gate (make-vl-gateinst :type :vl-or
                               :name "gate"
                               :args (list (make-vl-plainarg :expr out-expr :dir :vl-output)
                                           (make-vl-plainarg :expr a-expr   :dir :vl-input)
                                           (make-vl-plainarg :expr b-expr   :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     a-port     b-port)
                           :portdecls (list out-portdecl a-portdecl b-portdecl)
                           :netdecls  (list out-netdecl  a-netdecl  b-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-or*)))


(defxdoc *vl-1-bit-xor*
  :parents (primitives)
  :short "Primitive xor-gate module."
  :long "<p>The Verilog definition of this module is:</p>

@({
module VL_1_BIT_XOR (out, a, b) ;
  output out;
  input a;
  input b;
  xor gate (out, a, b);
endmodule
})

<p>VL takes this as a primitive.  We use this in place of @('xor') gates and
@('^') operators, and also in many modules we generate for other operators like
@('+').</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-xor*)</p>")

(defconsts *vl-1-bit-xor*
  (b* ((name "VL_1_BIT_XOR")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv a-expr   a-port   a-portdecl   a-netdecl)   (vl-primitive-mkport "a"   :vl-input))
       ((mv b-expr   b-port   b-portdecl   b-netdecl)   (vl-primitive-mkport "b"   :vl-input))
       (gate (make-vl-gateinst :type :vl-xor
                               :name "gate"
                               :args (list (make-vl-plainarg :expr out-expr :dir :vl-output)
                                           (make-vl-plainarg :expr a-expr   :dir :vl-input)
                                           (make-vl-plainarg :expr b-expr   :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     a-port     b-port)
                           :portdecls (list out-portdecl a-portdecl b-portdecl)
                           :netdecls  (list out-netdecl  a-netdecl  b-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-xor*)))


(defxdoc *vl-1-bit-nand*
  :parents (primitives)
  :short "Primitive nand-gate module."
  :long "<p>The Verilog definition of this module is:</p>

@({
module VL_1_BIT_NAND (out, a, b) ;
  output out;
  input a;
  input b;
  nand gate (out, a, b);
endmodule
})

<p>VL takes this as a primitive.  We use this in place of @('nand') gates but
probably not much else.</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-nand*)</p>")

(defconsts *vl-1-bit-nand*
  (b* ((name "VL_1_BIT_NAND")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv a-expr   a-port   a-portdecl   a-netdecl)   (vl-primitive-mkport "a"   :vl-input))
       ((mv b-expr   b-port   b-portdecl   b-netdecl)   (vl-primitive-mkport "b"   :vl-input))
       (gate (make-vl-gateinst :type :vl-nand
                               :name "gate"
                               :args (list (make-vl-plainarg :expr out-expr :dir :vl-output)
                                           (make-vl-plainarg :expr a-expr   :dir :vl-input)
                                           (make-vl-plainarg :expr b-expr   :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     a-port     b-port)
                           :portdecls (list out-portdecl a-portdecl b-portdecl)
                           :netdecls  (list out-netdecl  a-netdecl  b-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-nand*)))


(defxdoc *vl-1-bit-nor*
  :parents (primitives)
  :short "Primitive nor-gate module."
  :long "<p>The Verilog definition of this module is:</p>

@({
module VL_1_BIT_NOR (out, a, b) ;
  output out;
  input a;
  input b;
  nor gate (out, a, b);
endmodule
})

<p>VL takes this as a primitive.  We use this in place of @('nor') gates, but
probably not much else.</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-nor*)</p>")

(defconsts *vl-1-bit-nor*
  (b* ((name "VL_1_BIT_NOR")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv a-expr   a-port   a-portdecl   a-netdecl)   (vl-primitive-mkport "a"   :vl-input))
       ((mv b-expr   b-port   b-portdecl   b-netdecl)   (vl-primitive-mkport "b"   :vl-input))
       (gate (make-vl-gateinst :type :vl-nor
                               :name "gate"
                               :args (list (make-vl-plainarg :expr out-expr :dir :vl-output)
                                           (make-vl-plainarg :expr a-expr   :dir :vl-input)
                                           (make-vl-plainarg :expr b-expr   :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     a-port     b-port)
                           :portdecls (list out-portdecl a-portdecl b-portdecl)
                           :netdecls  (list out-netdecl  a-netdecl  b-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-nor*)))


(defxdoc *vl-1-bit-xnor*
  :parents (primitives)
  :short "Primitive xnor-gate module."
  :long "<p>The Verilog definition of this module is:</p>

@({
module VL_1_BIT_XNOR (out, a, b) ;
  output out;
  input a;
  input b;
  xnor gate (out, a, b);
endmodule
})

<p>VL takes this as a primitive.  We use this in place of @('xnor') gates, but
probably not much else.</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-xnor*)</p>")

(defconsts *vl-1-bit-xnor*
  ;; BOZO this should probably be a non-primitive.
  (b* ((name "VL_1_BIT_XNOR")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv a-expr   a-port   a-portdecl   a-netdecl)   (vl-primitive-mkport "a"   :vl-input))
       ((mv b-expr   b-port   b-portdecl   b-netdecl)   (vl-primitive-mkport "b"   :vl-input))
       (gate (make-vl-gateinst :type :vl-xnor
                               :name "gate"
                               :args (list (make-vl-plainarg :expr out-expr :dir :vl-output)
                                           (make-vl-plainarg :expr a-expr   :dir :vl-input)
                                           (make-vl-plainarg :expr b-expr   :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     a-port     b-port)
                           :portdecls (list out-portdecl a-portdecl b-portdecl)
                           :netdecls  (list out-netdecl  a-netdecl  b-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-xnor*)))

(defxdoc *vl-1-bit-approx-mux*
  :parents (primitives)
  :short "Primitive 1-bit (more conservative) multiplexor module."
  :long "<p>The Verilog definition of this module is:</p>

@({
module VL_1_BIT_APPROX_MUX (out, sel, a, b) ;
  output out;
  input sel;
  input a;
  input b;
  assign out = sel ? a : b;
endmodule
})

<p>VL takes this as a primitive, and we use it to implement @('?:')
expressions.  The corresponding @(see esim) primitive is @(see
acl2::*esim-safe-mux*).</p>

<p>The esim semantics are a <b>conservative, inexact approximation</b> of the
Verilog semantics, for two reasons.</p>

<h3>1. Z Input Handling</h3>

<p>In Verilog, the expression @('sel ? a : b') produces a @('Z') value when the
selected input is @('Z').  But our corresponding esim primitive produces X in
this case.</p>

<p>Occasionally, @('?:') operators with @('Z') inputs are used in Verilog
designs to model efficient muxes, based on tri-state buffers, where the selects
are expected to be one-hot.  For instance:</p>

@({
    assign out = sel1 ? data1 : 1'bz;
    assign out = sel2 ? data2 : 1'bz;
    assign out = sel3 ? data3 : 1'bz;
})

<p>Such a circuit could not be modeled correctly using approx-muxes; the esim
semantics would always produce an X on the output.  To avoid this, VL tries to
recognize @('?:') operators that literally are of the form @('a ?  b : Z'),
using a simple kind of pattern-matching, and in these cases it uses a different
primitive, @(see *vl-1-bit-zmux*), instead of approx muxes.</p>

<p>But in general, the Verilog semantics do not really correspond to any kind
of hardware that you would implement.  For instance, an AND/OR style mux would
always drive its output, regardless of whether its inputs were driven.  So the
ESIM semantics, which treat the output as X instead of Z in this case, are
arguably more realistic and safer than the Verilog semantics.</p>

<h3>2. X Select Handling</h3>

<p>In Verilog, when @('sel') evaluates to X or Z, the expression @('sel ? a :
b') may still produce a good 1 or 0 value when both data inputs @('a') and
@('b') share this value.</p>

<p>For certain kinds of mux implementations, this seems overly optimistic, and
our esim semantics for an approx mux is that whenever @('sel') is X, we output
is X, even if the inputs agree.  For more discussion about this issue and the
tradeoffs involved, see @(see acl2::4v-ite).</p>

<p>For special cases where this approximation is not acceptable, VL implements
a special @('VL_X_SELECT') that can be used to override this behavior.  @('?:')
operators that are annotated with this attribute will be implemented in a less
conservative way, as @(see *vl-1-bit-mux*) primitives.  See @(see
vl-mux-occform) for more information.</p>")

(defconsts *vl-1-bit-approx-mux*
  (b* ((name "VL_1_BIT_APPROX_MUX")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv sel-expr sel-port sel-portdecl sel-netdecl) (vl-primitive-mkport "sel" :vl-input))
       ((mv a-expr   a-port   a-portdecl   a-netdecl)   (vl-primitive-mkport "a"   :vl-input))
       ((mv b-expr   b-port   b-portdecl   b-netdecl)   (vl-primitive-mkport "b"   :vl-input))
       (assign (make-vl-assign :lvalue out-expr
                               :expr   (make-vl-nonatom :op :vl-qmark
                                                        :args (list sel-expr a-expr b-expr)
                                                        :finalwidth 1
                                                        :finaltype :vl-unsigned)
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     sel-port     a-port     b-port)
                           :portdecls (list out-portdecl sel-portdecl a-portdecl b-portdecl)
                           :netdecls  (list out-netdecl  sel-netdecl  a-netdecl  b-netdecl)
                           :assigns   (list assign)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-safe-mux*)))


(defxdoc *vl-1-bit-mux*
  :parents (primitives)
  :short "Primitive 1-bit (less conservative) multiplexor module."
  :long "<p>The Verilog definition of this module is:</p>

@({
module VL_1_BIT_MUX (out, sel, a, b) ;
  output out;
  input sel;
  input a;
  input b;
  assign out = sel ? a : b;
endmodule
})

<p>VL takes this as a primitive.  The corresponding @(see esim) primitive is
@(see acl2::*esim-unsafe-mux*).</p>

<p>Ordinarily, VL <b>will not use this module</b>.  Instead, @('?:') operators
will be implemented using either @(see *vl-1-bit-approx-mux*) or @(see
*vl-1-bit-zmux*) modules.</p>

<p>The only reason we have this module at all is that, occasionally, you may
find that an approx mux is too conservative.  If this causes you problems, you
may instruct VL to instead produce a less-conservative @('*vl-1-bit-mux*') by
adding a @('VL_X_SELECT') attribute; see @(see vl-mux-occform) for more
information.</p>

<p>In the ESIM semantics, a @('*vl-1-bit-mux*') is identical to a
@('*vl-1-bit-approx-mux*') except in the cases where the select is unknown (X
or Z) and the data inputs agree on some good, Boolean value.  For instance:</p>

<ul>
<li> X ? 1 : 1 </li>
<li> X ? 0 : 0 </li>
</ul>

<p>In these cases, an approx-mux produces @('X'), whereas a non-approx mux will
produce the shared value of the data inputs.</p>

<p>This less-conservative behavior may not necessarily be a realistic model of
how some physical muxes will operate, and may lead to somewhat slower symbolic
simulation performance in certain cases.  For additional discussion of these
issues, see @(see *vl-1-bit-approx-mux*) and @(see acl2::4v-ite).</p>

<p>Note that, like an approx-mux, a @('vl-1-bit-mux') still produces X when the
selected data input is Z.</p>")

(defconsts *vl-1-bit-mux*
  (b* ((name "VL_1_BIT_MUX")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv sel-expr sel-port sel-portdecl sel-netdecl) (vl-primitive-mkport "sel" :vl-input))
       ((mv a-expr   a-port   a-portdecl   a-netdecl)   (vl-primitive-mkport "a"   :vl-input))
       ((mv b-expr   b-port   b-portdecl   b-netdecl)   (vl-primitive-mkport "b"   :vl-input))
       (assign (make-vl-assign :lvalue out-expr
                               :expr   (make-vl-nonatom :op :vl-qmark
                                                        :args (list sel-expr a-expr b-expr)
                                                        :finalwidth 1
                                                        :finaltype :vl-unsigned)
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     sel-port     a-port     b-port)
                           :portdecls (list out-portdecl sel-portdecl a-portdecl b-portdecl)
                           :netdecls  (list out-netdecl  sel-netdecl  a-netdecl  b-netdecl)
                           :assigns   (list assign)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-unsafe-mux*)))


(defxdoc *vl-1-bit-zmux*
  :parents (primitives)
  :short "Primitive tri-state buffer module."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_ZMUX (out, sel, a);
  output out;
  input sel;
  input a;
  assign out = sel ? a : 1'bZ;
endmodule
})

<p>VL takes this as a primitive.  It is used in @(see vl-mux-occform) as the
basis for conditional expressions with @('Z') branches that are typically used
to implement muxes.</p>

<p>Verilog truth table:</p>

@({
  sel    a    |   out         sel    a        out
 -------------+---------     -------------+-----------
   0     0    |    z           x     0    |    x
   0     1    |    z           x     1    |    x
   0     x    |    z           x     x    |    x
   0     z    |    z           x     z    |    x
   1     0    |    0           z     0    |    x
   1     1    |    1           z     1    |    x
   1     x    |    x           z     x    |    x
   1     z    |    z           z     z    |    x
})

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-tri*), which
drives its output to @('(tristate sel a)'); see @(see acl2::4v-tristate).  This
matches the Verilog truth table exactly.</p>")

(defconsts *vl-1-bit-zmux*
  (b* ((name "VL_1_BIT_ZMUX")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv sel-expr sel-port sel-portdecl sel-netdecl) (vl-primitive-mkport "sel" :vl-input))
       ((mv a-expr a-port a-portdecl a-netdecl)         (vl-primitive-mkport "a" :vl-input))
       (assign (make-vl-assign :lvalue out-expr
                               :expr (make-vl-nonatom :op :vl-qmark
                                                      :args (list sel-expr a-expr |*sized-1'bz*|)
                                                      :finalwidth 1
                                                      :finaltype :vl-unsigned)
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :ports     (list out-port     sel-port     a-port)
                           :portdecls (list out-portdecl sel-portdecl a-portdecl)
                           :netdecls  (list out-netdecl  sel-netdecl  a-netdecl)
                           :assigns   (list assign)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :origname  name
                           :esim      acl2::*esim-tri*)))


(defxdoc *vl-1-bit-ceq*
  :parents (primitives)
  :short "Primitive @('===') module."
  :long "<p>The Verilog definition of this module is:</p>

@({
module VL_1_BIT_CEQ (out, a, b) ;
  output out;
  input a;
  input b;
  assign out = (a === b);
endmodule
})

<p>VL takes this as a primitive, and uses it to implement @('===') and @('!==')
operators.</p>

<p>These operators are inherently unsound because they do not treat @('X') as
an unknown.  For our back-end tools, we usually conservatively approximate
@('VL_1_BIT_CEQ') with an @('xnor') gate.  But a less conservative tool might
choose to give it a different interpretation.</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-ceq*), which is
just an @('xnor') gate.</p>")

(defconsts *vl-1-bit-ceq*
  ;; BOZO this should probably be a non-primitive.
  (b* ((name "VL_1_BIT_CEQ")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv a-expr   a-port   a-portdecl   a-netdecl)   (vl-primitive-mkport "a"   :vl-input))
       ((mv b-expr   b-port   b-portdecl   b-netdecl)   (vl-primitive-mkport "b"   :vl-input))
       (assign (make-vl-assign :lvalue out-expr
                               :expr (make-vl-nonatom :op :vl-binary-ceq
                                                      :args (list a-expr b-expr)
                                                      :finalwidth 1
                                                      :finaltype :vl-unsigned)
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     a-port     b-port)
                           :portdecls (list out-portdecl a-portdecl b-portdecl)
                           :netdecls  (list out-netdecl  a-netdecl  b-netdecl)
                           :assigns   (list assign)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-ceq*)))



(defxdoc *vl-1-bit-flop*
  :parents (primitives)
  :short "Primitive edge-triggered register."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_FLOP (q, clk, d) ;
  output reg q;
  input clk;
  input d;

  always @@(posedge clk)
     q <= d;

endmodule
})

<p>VL takes this as a primitive.  The @(see always-top) transform converts
certain @('always') statements into instances of this module.</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-flop*).</p>")

(defconsts *vl-1-bit-flop*
  (b* ((name "VL_1_BIT_FLOP")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))

       ((mv q-expr   q-port   q-portdecl   &)           (vl-primitive-mkport "q"   :vl-output))
       ((mv clk-expr clk-port clk-portdecl clk-netdecl) (vl-primitive-mkport "clk" :vl-input))
       ((mv d-expr   d-port   d-portdecl   d-netdecl)   (vl-primitive-mkport "d"   :vl-input))

       (q-regdecl    (make-vl-regdecl :name "q" :loc *vl-fakeloc*))

       ;; always @(posedge clk) q <= d;
       (q<=d         (make-vl-assignstmt :type :vl-nonblocking :lvalue q-expr :expr d-expr :loc *vl-fakeloc*))
       (posedge-clk  (make-vl-evatom :type :vl-posedge :expr clk-expr))
       (@posedge-clk (make-vl-eventcontrol :starp nil :atoms (list posedge-clk)))
       (stmt         (make-vl-timingstmt :ctrl @posedge-clk :body q<=d))
       (always       (make-vl-always :stmt stmt :loc *vl-fakeloc*)))

    (make-honsed-vl-module :name      name
                           :origname  name
                           :atts      atts
                           :ports     (list q-port      clk-port     d-port)
                           :portdecls (list q-portdecl  clk-portdecl d-portdecl)
                           :netdecls  (list             clk-netdecl  d-netdecl)
                           :regdecls  (list q-regdecl)
                           :alwayses  (list always)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :esim      acl2::*esim-flop*)))


(defxdoc *vl-1-bit-latch*
  :parents (primitives)
  :short "Primitive level-sensitive latch."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_LATCH (q, clk, d);
   output reg q;
   input clk;
   input d;

   always @@(d or clk)
     q <= clk ? d : q;

endmodule
})

<p>VL takes this as a primitive.  The @(see always-top) transform converts
certain @('always') statements into instances of this module.</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-latch*).</p>")

(defconsts *vl-1-bit-latch*
  (b* ((name (hons-copy "VL_1_BIT_LATCH"))
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))

       ((mv q-expr   q-port   q-portdecl   &)           (vl-primitive-mkport "q"   :vl-output))
       ((mv clk-expr clk-port clk-portdecl clk-netdecl) (vl-primitive-mkport "clk" :vl-input))
       ((mv d-expr   d-port   d-portdecl   d-netdecl)   (vl-primitive-mkport "d"   :vl-input))

       (q-regdecl     (make-vl-regdecl :name "q" :loc *vl-fakeloc*))

       ;; always @(d or clk) q <= clk ? d : q;
       (|clk?d:q|     (make-vl-nonatom :op :vl-qmark
                                       :args (list clk-expr d-expr q-expr)
                                       :finalwidth 1
                                       :finaltype :vl-unsigned))
       (|q<=clk?d:q|  (make-vl-assignstmt :type :vl-nonblocking
                                          :lvalue q-expr
                                          :expr |clk?d:q|
                                          :loc *vl-fakeloc*))
       (d-evatom      (make-vl-evatom :type :vl-noedge :expr d-expr))
       (clk-evatom    (make-vl-evatom :type :vl-noedge :expr clk-expr))
       (@d-or-clk     (make-vl-eventcontrol :starp nil :atoms (list d-evatom clk-evatom)))
       (stmt          (make-vl-timingstmt :ctrl @d-or-clk :body |q<=clk?d:q|))
       (always        (make-vl-always :stmt stmt :loc *vl-fakeloc*)))

    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list q-port     clk-port     d-port)
                           :portdecls (list q-portdecl clk-portdecl d-portdecl)
                           :netdecls  (list            clk-netdecl  d-netdecl)
                           :regdecls  (list q-regdecl)
                           :alwayses  (list always)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-latch*)))


(defxdoc *vl-1-bit-bufif0*
  :parents (primitives)
  :short "Primitive conditional driver."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_BUFIF0 (out, data, ctrl);
   output out;
   input data;
   input ctrl;
   bufif0 gate (out, data, ctrl);
endmodule
})

<p>VL takes this as a primitive.  The @(see gate-elim) transform converts
certain @('bufif0') gates into instances of this module.</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-bufif0*).</p>")

(defconsts *vl-1-bit-bufif0*
  (b* ((name "VL_1_BIT_BUFIF0")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv data-expr   data-port   data-portdecl   data-netdecl)   (vl-primitive-mkport "data"   :vl-input))
       ((mv ctrl-expr   ctrl-port   ctrl-portdecl   ctrl-netdecl)   (vl-primitive-mkport "ctrl"   :vl-input))
       (gate (make-vl-gateinst :type :vl-bufif0
                               :name "gate"
                               :args (list (make-vl-plainarg :expr out-expr :dir :vl-output)
                                           (make-vl-plainarg :expr data-expr   :dir :vl-input)
                                           (make-vl-plainarg :expr ctrl-expr   :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     data-port     ctrl-port)
                           :portdecls (list out-portdecl data-portdecl ctrl-portdecl)
                           :netdecls  (list out-netdecl  data-netdecl  ctrl-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-bufif0*)))


(defxdoc *vl-1-bit-bufif1*
  :parents (primitives)
  :short "Primitive conditional driver."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_BUFIF1 (out, data, ctrl);
   output out;
   input data;
   input ctrl;
   bufif1 gate (out, data, ctrl);
endmodule
})

<p>VL takes this as a primitive.  The @(see gate-elim) transform converts
certain @('bufif1') gates into instances of this module.</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-bufif1*).</p>")

(defconsts *vl-1-bit-bufif1*
  (b* ((name "VL_1_BIT_BUFIF1")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv data-expr   data-port   data-portdecl   data-netdecl)   (vl-primitive-mkport "data"   :vl-input))
       ((mv ctrl-expr   ctrl-port   ctrl-portdecl   ctrl-netdecl)   (vl-primitive-mkport "ctrl"   :vl-input))
       (gate (make-vl-gateinst :type :vl-bufif1
                               :name "gate"
                               :args (list (make-vl-plainarg :expr out-expr :dir :vl-output)
                                           (make-vl-plainarg :expr data-expr   :dir :vl-input)
                                           (make-vl-plainarg :expr ctrl-expr   :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     data-port     ctrl-port)
                           :portdecls (list out-portdecl data-portdecl ctrl-portdecl)
                           :netdecls  (list out-netdecl  data-netdecl  ctrl-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-bufif1*)))

(defxdoc *vl-1-bit-notif0*
  :parents (primitives)
  :short "Primitive conditional driver."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_NOTIF0 (out, data, ctrl);
   output out;
   input data;
   input ctrl;
   notif0 gate (out, data, ctrl);
endmodule
})

<p>VL takes this as a primitive.  The @(see gate-elim) transform converts
certain @('notif0') gates into instances of this module.</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-notif0*).</p>")

(defconsts *vl-1-bit-notif0*
  (b* ((name "VL_1_BIT_NOTIF0")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv data-expr   data-port   data-portdecl   data-netdecl)   (vl-primitive-mkport "data"   :vl-input))
       ((mv ctrl-expr   ctrl-port   ctrl-portdecl   ctrl-netdecl)   (vl-primitive-mkport "ctrl"   :vl-input))
       (gate (make-vl-gateinst :type :vl-notif0
                               :name "gate"
                               :args (list (make-vl-plainarg :expr out-expr :dir :vl-output)
                                           (make-vl-plainarg :expr data-expr   :dir :vl-input)
                                           (make-vl-plainarg :expr ctrl-expr   :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     data-port     ctrl-port)
                           :portdecls (list out-portdecl data-portdecl ctrl-portdecl)
                           :netdecls  (list out-netdecl  data-netdecl  ctrl-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-notif0*)))

(defxdoc *vl-1-bit-notif1*
  :parents (primitives)
  :short "Primitive conditional driver."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_NOTIF1 (out, data, ctrl);
   output out;
   input data;
   input ctrl;
   notif1 gate (out, data, ctrl);
endmodule
})

<p>VL takes this as a primitive.  The @(see gate-elim) transform converts
certain @('notif1') gates into instances of this module.</p>

<p>The corresponding @(see esim) primitive is @(see acl2::*esim-notif1*).</p>")

(defconsts *vl-1-bit-notif1*
  (b* ((name "VL_1_BIT_NOTIF1")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv data-expr   data-port   data-portdecl   data-netdecl)   (vl-primitive-mkport "data"   :vl-input))
       ((mv ctrl-expr   ctrl-port   ctrl-portdecl   ctrl-netdecl)   (vl-primitive-mkport "ctrl"   :vl-input))
       (gate (make-vl-gateinst :type :vl-notif1
                               :name "gate"
                               :args (list (make-vl-plainarg :expr out-expr :dir :vl-output)
                                           (make-vl-plainarg :expr data-expr   :dir :vl-input)
                                           (make-vl-plainarg :expr ctrl-expr   :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     data-port     ctrl-port)
                           :portdecls (list out-portdecl data-portdecl ctrl-portdecl)
                           :netdecls  (list out-netdecl  data-netdecl  ctrl-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-notif1*)))


(defxdoc *vl-1-bit-nmos*
  :parents (primitives)
  :short "Primitive nmos transistor."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_NMOS (out, data, ctrl);
  output out ;
  input data ;
  input ctrl ;
  nmos gate (out, data, ctrl) ;
endmodule
})

<p>VL takes this as a primitive.  The @(see gate-elim) transform converts
certain @('nmos') gates into instances of this module.</p>

<p>ESIM has very little support for transistors, but this may be a useful
target for other back-end tools.  The corresponding @(see esim) primitive is
@(see acl2::*esim-nmos*).</p>")

(defconsts *vl-1-bit-nmos*
  (b* ((name "VL_1_BIT_NMOS")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv data-expr   data-port   data-portdecl   data-netdecl)   (vl-primitive-mkport "data"   :vl-input))
       ((mv ctrl-expr   ctrl-port   ctrl-portdecl   ctrl-netdecl)   (vl-primitive-mkport "ctrl"   :vl-input))
       (gate (make-vl-gateinst :type :vl-nmos
                               :name "gate"
                               :args (list (make-vl-plainarg :expr out-expr :dir :vl-output)
                                           (make-vl-plainarg :expr data-expr   :dir :vl-input)
                                           (make-vl-plainarg :expr ctrl-expr   :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     data-port     ctrl-port)
                           :portdecls (list out-portdecl data-portdecl ctrl-portdecl)
                           :netdecls  (list out-netdecl  data-netdecl  ctrl-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-nmos*)))


(defxdoc *vl-1-bit-rnmos*
  :parents (primitives)
  :short "Primitive resistive nmos transistor."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_RNMOS (out, data, ctrl);
  output out ;
  input data ;
  input ctrl ;
  rnmos gate (out, data, ctrl) ;
endmodule
})

<p>VL takes this as a primitive.  The @(see gate-elim) transform converts
certain @('rnmos') gates into instances of this module.</p>

<p>ESIM has no notion of strengths and very little support for transistors, but
this may be a convenient target for other back-end tools.  The corresponding
@(see esim) primitive is @(see acl2::*esim-nmos*).</p>")

(defconsts *vl-1-bit-rnmos*
  (b* ((name "VL_1_BIT_RNMOS")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv data-expr   data-port   data-portdecl   data-netdecl)   (vl-primitive-mkport "data"   :vl-input))
       ((mv ctrl-expr   ctrl-port   ctrl-portdecl   ctrl-netdecl)   (vl-primitive-mkport "ctrl"   :vl-input))
       (gate (make-vl-gateinst :type :vl-rnmos
                               :name "gate"
                               :args (list (make-vl-plainarg :expr out-expr :dir :vl-output)
                                           (make-vl-plainarg :expr data-expr   :dir :vl-input)
                                           (make-vl-plainarg :expr ctrl-expr   :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     data-port     ctrl-port)
                           :portdecls (list out-portdecl data-portdecl ctrl-portdecl)
                           :netdecls  (list out-netdecl  data-netdecl  ctrl-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-nmos*)))


(defxdoc *vl-1-bit-pmos*
  :parents (primitives)
  :short "Primitive pmos transistor."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_PMOS (out, data, ctrl);
  output out ;
  input data ;
  input ctrl ;
  pmos gate (out, data, ctrl) ;
endmodule
})

<p>VL takes this as a primitive.  The @(see gate-elim) transform converts
certain @('pmos') gates into instances of this module.</p>

<p>ESIM has very little support for transistors, but this may be a useful
target for other back-end tools.  The corresponding @(see esim) primitive is
@(see acl2::*esim-pmos*).</p>")

(defconsts *vl-1-bit-pmos*
  (b* ((name "VL_1_BIT_PMOS")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv data-expr   data-port   data-portdecl   data-netdecl)   (vl-primitive-mkport "data"   :vl-input))
       ((mv ctrl-expr   ctrl-port   ctrl-portdecl   ctrl-netdecl)   (vl-primitive-mkport "ctrl"   :vl-input))
       (gate (make-vl-gateinst :type :vl-pmos
                               :name "gate"
                               :args (list (make-vl-plainarg :expr out-expr :dir :vl-output)
                                           (make-vl-plainarg :expr data-expr   :dir :vl-input)
                                           (make-vl-plainarg :expr ctrl-expr   :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     data-port     ctrl-port)
                           :portdecls (list out-portdecl data-portdecl ctrl-portdecl)
                           :netdecls  (list out-netdecl  data-netdecl  ctrl-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-pmos*)))

(defxdoc *vl-1-bit-rpmos*
  :parents (primitives)
  :short "Primitive resistive pmos transistor."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_RPMOS (out, data, ctrl);
  output out ;
  input data ;
  input ctrl ;
  rpmos gate (out, data, ctrl) ;
endmodule
})

<p>VL takes this as a primitive.  The @(see gate-elim) transform converts
certain @('rpmos') gates into instances of this module.</p>

<p>ESIM has no notion of strengths and very little support for transistors, but
this may be a convenient target for other back-end tools.  The corresponding
@(see esim) primitive is @(see acl2::*esim-nmos*).</p>")

(defconsts *vl-1-bit-rpmos*
  (b* ((name "VL_1_BIT_RPMOS")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
       ((mv data-expr   data-port   data-portdecl   data-netdecl)   (vl-primitive-mkport "data"   :vl-input))
       ((mv ctrl-expr   ctrl-port   ctrl-portdecl   ctrl-netdecl)   (vl-primitive-mkport "ctrl"   :vl-input))
       (gate (make-vl-gateinst :type :vl-rpmos
                               :name "gate"
                               :args (list (make-vl-plainarg :expr out-expr :dir :vl-output)
                                           (make-vl-plainarg :expr data-expr   :dir :vl-input)
                                           (make-vl-plainarg :expr ctrl-expr   :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     data-port     ctrl-port)
                           :portdecls (list out-portdecl data-portdecl ctrl-portdecl)
                           :netdecls  (list out-netdecl  data-netdecl  ctrl-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-pmos*)))

(defxdoc *vl-1-bit-cmos*
  :parents (primitives)
  :short "Primitive cmos transistor."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_CMOS (out, data, nctrl, pctrl);
  output out ;
  input data ;
  input nctrl ;
  input pctrl ;
  cmos gate (out, data, nctrl, pctrl) ;
endmodule
})

<p>VL takes this as a primitive.  The @(see gate-elim) transform converts
certain @('cmos') gates into instances of this module.</p>

<p>ESIM has very little support for transistors, but this may be a useful
target for other back-end tools.  The corresponding @(see esim) primitive is
@(see acl2::*esim-cmos*).</p>")

(defconsts *vl-1-bit-cmos*
  (b* ((name "VL_1_BIT_CMOS")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr    out-port    out-portdecl    out-netdecl)    (vl-primitive-mkport "out"   :vl-output))
       ((mv data-expr   data-port   data-portdecl   data-netdecl)   (vl-primitive-mkport "data"  :vl-input))
       ((mv nctrl-expr  nctrl-port  nctrl-portdecl  nctrl-netdecl)  (vl-primitive-mkport "nctrl" :vl-input))
       ((mv pctrl-expr  pctrl-port  pctrl-portdecl  pctrl-netdecl)  (vl-primitive-mkport "pctrl" :vl-input))
       (gate (make-vl-gateinst :type :vl-cmos
                               :name "gate"
                               :args (list (make-vl-plainarg :expr out-expr   :dir :vl-output)
                                           (make-vl-plainarg :expr data-expr  :dir :vl-input)
                                           (make-vl-plainarg :expr nctrl-expr :dir :vl-input)
                                           (make-vl-plainarg :expr pctrl-expr :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     data-port     nctrl-port     pctrl-port)
                           :portdecls (list out-portdecl data-portdecl nctrl-portdecl pctrl-portdecl)
                           :netdecls  (list out-netdecl  data-netdecl  nctrl-netdecl  pctrl-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-cmos*)))

(defxdoc *vl-1-bit-rcmos*
  :parents (primitives)
  :short "Primitive resistive cmos transistor."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_RCMOS (out, data, nctrl, pctrl);
  output out ;
  input data ;
  input nctrl ;
  input pctrl ;
  rcmos gate (out, data, nctrl, pctrl) ;
endmodule
})

<p>VL takes this as a primitive.  The @(see gate-elim) transform converts
certain @('rcmos') gates into instances of this module.</p>

<p>ESIM has no notion of strengths and very little support for transistors, but
this may be a convenient target for other back-end tools.  The corresponding
@(see esim) primitive is @(see acl2::*esim-cmos*).</p>")

(defconsts *vl-1-bit-rcmos*
  (b* ((name "VL_1_BIT_RCMOS")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr    out-port    out-portdecl    out-netdecl)    (vl-primitive-mkport "out"   :vl-output))
       ((mv data-expr   data-port   data-portdecl   data-netdecl)   (vl-primitive-mkport "data"  :vl-input))
       ((mv nctrl-expr  nctrl-port  nctrl-portdecl  nctrl-netdecl)  (vl-primitive-mkport "nctrl" :vl-input))
       ((mv pctrl-expr  pctrl-port  pctrl-portdecl  pctrl-netdecl)  (vl-primitive-mkport "pctrl" :vl-input))
       (gate (make-vl-gateinst :type :vl-rcmos
                               :name "gate"
                               :args (list (make-vl-plainarg :expr out-expr   :dir :vl-output)
                                           (make-vl-plainarg :expr data-expr  :dir :vl-input)
                                           (make-vl-plainarg :expr nctrl-expr :dir :vl-input)
                                           (make-vl-plainarg :expr pctrl-expr :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port     data-port     nctrl-port     pctrl-port)
                           :portdecls (list out-portdecl data-portdecl nctrl-portdecl pctrl-portdecl)
                           :netdecls  (list out-netdecl  data-netdecl  nctrl-netdecl  pctrl-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      acl2::*esim-cmos*)))

(defxdoc *vl-1-bit-tran*
  :parents (primitives)
  :short "Primitive bidirectional connection."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_TRAN (a, b);
  inout a ;
  inout b ;
  tran gate (a, b) ;
endmodule
})

<p>VL takes this as a primitive.  The @(see gate-elim) transform converts
certain @('tran') gates into instances of this module.</p>

<p>There is no sensible way to model this in ESIM and hence there is no ESIM
equivalent.  However, this module may be a convenient target for other back-end
tools.</p>")

(defconsts *vl-1-bit-tran*
  (b* ((name "VL_1_BIT_TRAN")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv a-expr    a-port    a-portdecl    a-netdecl)    (vl-primitive-mkport "a"   :vl-inout))
       ((mv b-expr    b-port    b-portdecl    b-netdecl)    (vl-primitive-mkport "b"   :vl-inout))
       (gate (make-vl-gateinst :type :vl-tran
                               :name "gate"
                               :args (list (make-vl-plainarg :expr a-expr  :dir :vl-inout)
                                           (make-vl-plainarg :expr b-expr  :dir :vl-inout))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list a-port     b-port)
                           :portdecls (list a-portdecl b-portdecl)
                           :netdecls  (list a-netdecl  b-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      nil   ;; no e equivalent
                           )))

(defxdoc *vl-1-bit-rtran*
  :parents (primitives)
  :short "Primitive, resistive bidirectional connection."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_RTRAN (a, b);
  inout a ;
  inout b ;
  rtran gate (a, b) ;
endmodule
})

<p>VL takes this as a primitive.  The @(see gate-elim) transform converts
certain @('rtran') gates into instances of this module.</p>

<p>There is no sensible way to model this in ESIM and hence there is no ESIM
equivalent.  However, this module may be a convenient target for other back-end
tools.</p>")

(defconsts *vl-1-bit-rtran*
  (b* ((name "VL_1_BIT_RTRAN")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv a-expr    a-port    a-portdecl    a-netdecl)    (vl-primitive-mkport "a"   :vl-inout))
       ((mv b-expr    b-port    b-portdecl    b-netdecl)    (vl-primitive-mkport "b"   :vl-inout))
       (gate (make-vl-gateinst :type :vl-rtran
                               :name "gate"
                               :args (list (make-vl-plainarg :expr a-expr  :dir :vl-inout)
                                           (make-vl-plainarg :expr b-expr  :dir :vl-inout))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list a-port     b-port)
                           :portdecls (list a-portdecl b-portdecl)
                           :netdecls  (list a-netdecl  b-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      nil   ;; no e equivalent
                           )))

(defxdoc *vl-1-bit-tranif0*
  :parents (primitives)
  :short "Primitive, conditional bidirectional connection."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_TRANIF0 (a, b, ctrl);
  inout a ;
  inout b ;
  input ctrl ;
  tranif0 gate (a, b, ctrl) ;
endmodule
})

<p>VL takes this as a primitive.  The @(see gate-elim) transform converts
certain @('tranif0') gates into instances of this module.</p>

<p>There is no sensible way to model this in ESIM and hence there is no ESIM
equivalent.  However, this module may be a convenient target for other back-end
tools.</p>")

(defconsts *vl-1-bit-tranif0*
  (b* ((name "VL_1_BIT_TRANIF0")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv a-expr    a-port    a-portdecl    a-netdecl)    (vl-primitive-mkport "a"   :vl-inout))
       ((mv b-expr    b-port    b-portdecl    b-netdecl)    (vl-primitive-mkport "b"   :vl-inout))
       ((mv ctrl-expr ctrl-port ctrl-portdecl ctrl-netdecl) (vl-primitive-mkport "ctrl"   :vl-input))
       (gate (make-vl-gateinst :type :vl-tranif0
                               :name "gate"
                               :args (list (make-vl-plainarg :expr a-expr    :dir :vl-inout)
                                           (make-vl-plainarg :expr b-expr    :dir :vl-inout)
                                           (make-vl-plainarg :expr ctrl-expr :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list a-port     b-port     ctrl-port)
                           :portdecls (list a-portdecl b-portdecl ctrl-portdecl)
                           :netdecls  (list a-netdecl  b-netdecl  ctrl-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      nil   ;; no e equivalent
                           )))



(defxdoc *vl-1-bit-rtranif0*
  :parents (primitives)
  :short "Primitive, resistive, conditional bidirectional connection."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_RTRANIF0 (a, b, ctrl);
  inout a ;
  inout b ;
  input ctrl ;
  rtranif0 gate (a, b, ctrl) ;
endmodule
})

<p>VL takes this as a primitive.  The @(see gate-elim) transform converts
certain @('rtranif0') gates into instances of this module.</p>

<p>There is no sensible way to model this in ESIM and hence there is no ESIM
equivalent.  However, this module may be a convenient target for other back-end
tools.</p>")

(defconsts *vl-1-bit-rtranif0*
  (b* ((name "VL_1_BIT_RTRANIF0")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv a-expr    a-port    a-portdecl    a-netdecl)    (vl-primitive-mkport "a"   :vl-inout))
       ((mv b-expr    b-port    b-portdecl    b-netdecl)    (vl-primitive-mkport "b"   :vl-inout))
       ((mv ctrl-expr ctrl-port ctrl-portdecl ctrl-netdecl) (vl-primitive-mkport "ctrl"   :vl-input))
       (gate (make-vl-gateinst :type :vl-rtranif0
                               :name "gate"
                               :args (list (make-vl-plainarg :expr a-expr    :dir :vl-inout)
                                           (make-vl-plainarg :expr b-expr    :dir :vl-inout)
                                           (make-vl-plainarg :expr ctrl-expr :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list a-port     b-port     ctrl-port)
                           :portdecls (list a-portdecl b-portdecl ctrl-portdecl)
                           :netdecls  (list a-netdecl  b-netdecl  ctrl-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      nil   ;; no e equivalent
                           )))


(defxdoc *vl-1-bit-tranif1*
  :parents (primitives)
  :short "Primitive, conditional bidirectional connection."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_TRANIF1 (a, b, ctrl);
  inout a ;
  inout b ;
  input ctrl ;
  tranif1 gate (a, b, ctrl) ;
endmodule
})

<p>VL takes this as a primitive.  The @(see gate-elim) transform converts
certain @('tranif1') gates into instances of this module.</p>

<p>There is no sensible way to model this in ESIM and hence there is no ESIM
equivalent.  However, this module may be a convenient target for other back-end
tools.</p>")

(defconsts *vl-1-bit-tranif1*
  (b* ((name "VL_1_BIT_TRANIF1")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv a-expr    a-port    a-portdecl    a-netdecl)    (vl-primitive-mkport "a"   :vl-inout))
       ((mv b-expr    b-port    b-portdecl    b-netdecl)    (vl-primitive-mkport "b"   :vl-inout))
       ((mv ctrl-expr ctrl-port ctrl-portdecl ctrl-netdecl) (vl-primitive-mkport "ctrl"   :vl-input))
       (gate (make-vl-gateinst :type :vl-tranif1
                               :name "gate"
                               :args (list (make-vl-plainarg :expr a-expr    :dir :vl-inout)
                                           (make-vl-plainarg :expr b-expr    :dir :vl-inout)
                                           (make-vl-plainarg :expr ctrl-expr :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list a-port     b-port     ctrl-port)
                           :portdecls (list a-portdecl b-portdecl ctrl-portdecl)
                           :netdecls  (list a-netdecl  b-netdecl  ctrl-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      nil   ;; no e equivalent
                           )))

(defxdoc *vl-1-bit-rtranif1*
  :parents (primitives)
  :short "Primitive, resistive, conditional bidirectional connection."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_RTRANIF1 (a, b, ctrl);
  inout a ;
  inout b ;
  input ctrl ;
  rtranif1 gate (a, b, ctrl) ;
endmodule
})

<p>VL takes this as a primitive.  The @(see gate-elim) transform converts
certain @('rtranif1') gates into instances of this module.</p>

<p>There is no sensible way to model this in ESIM and hence there is no ESIM
equivalent.  However, this module may be a convenient target for other back-end
tools.</p>")

(defconsts *vl-1-bit-rtranif1*
  (b* ((name "VL_1_BIT_RTRANIF1")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv a-expr    a-port    a-portdecl    a-netdecl)    (vl-primitive-mkport "a"   :vl-inout))
       ((mv b-expr    b-port    b-portdecl    b-netdecl)    (vl-primitive-mkport "b"   :vl-inout))
       ((mv ctrl-expr ctrl-port ctrl-portdecl ctrl-netdecl) (vl-primitive-mkport "ctrl"   :vl-input))
       (gate (make-vl-gateinst :type :vl-rtranif1
                               :name "gate"
                               :args (list (make-vl-plainarg :expr a-expr    :dir :vl-inout)
                                           (make-vl-plainarg :expr b-expr    :dir :vl-inout)
                                           (make-vl-plainarg :expr ctrl-expr :dir :vl-input))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list a-port     b-port     ctrl-port)
                           :portdecls (list a-portdecl b-portdecl ctrl-portdecl)
                           :netdecls  (list a-netdecl  b-netdecl  ctrl-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      nil   ;; no e equivalent
                           )))

(defxdoc *vl-1-bit-pullup*
  :parents (primitives)
  :short "Primitive pullup element."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_PULLUP (a, b, ctrl);
  output out;
  pullup gate (out);
endmodule
})

<p>VL takes this as a primitive.  The @(see gate-elim) transform converts
certain @('pullup') gates into instances of this module.</p>

<p>There is no sensible way to model this in ESIM and hence there is no ESIM
equivalent.  However, this module may be a convenient target for other back-end
tools.</p>")

(defconsts *vl-1-bit-pullup*
  (b* ((name "VL_1_BIT_PULLUP")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr    out-port    out-portdecl    out-netdecl)    (vl-primitive-mkport "out"   :vl-output))
       (gate (make-vl-gateinst :type :vl-pullup
                               :name "gate"
                               :args (list (make-vl-plainarg :expr out-expr    :dir :vl-output))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port)
                           :portdecls (list out-portdecl)
                           :netdecls  (list out-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      nil   ;; no e equivalent
                           )))

(defxdoc *vl-1-bit-pulldown*
  :parents (primitives)
  :short "Primitive pulldown element."
  :long "<p>The Verilog meaning of this module is:</p>

@({
module VL_1_BIT_PULLDOWN (a, b, ctrl);
  output out;
  pulldown gate (out);
endmodule
})

<p>VL takes this as a primitive.  The @(see gate-elim) transform converts
certain @('pulldown') gates into instances of this module.</p>

<p>There is no sensible way to model this in ESIM and hence there is no ESIM
equivalent.  However, this module may be a convenient target for other back-end
tools.</p>")

(defconsts *vl-1-bit-pulldown*
  (b* ((name "VL_1_BIT_PULLDOWN")
       (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
       ((mv out-expr    out-port    out-portdecl    out-netdecl)    (vl-primitive-mkport "out"   :vl-output))
       (gate (make-vl-gateinst :type :vl-pulldown
                               :name "gate"
                               :args (list (make-vl-plainarg :expr out-expr    :dir :vl-output))
                               :loc *vl-fakeloc*)))
    (make-honsed-vl-module :name      name
                           :origname  name
                           :ports     (list out-port)
                           :portdecls (list out-portdecl)
                           :netdecls  (list out-netdecl)
                           :gateinsts (list gate)
                           :minloc    *vl-fakeloc*
                           :maxloc    *vl-fakeloc*
                           :atts      atts
                           :esim      nil   ;; no e equivalent
                           )))



;; BOZO this is a whole family of primitives, I guess

;; (defxdoc *vl-1-bit-resolve-wire*
;;   :parents (primitives)
;;   :short "Primitive module that resolves multiple drivers on a wire."
;;   :long "<p>The Verilog definition of this module is:</p>

;; @({
;; module VL_1_BIT_RESOLVE_WIRE (out, a, b) ;
;;   output out;
;;   input a;
;;   input b;
;;   assign out = a;
;;   assign out = b;
;; endmodule
;; })

;; <p>VL takes this as a primitive.  This module, and wrappers that extend it to
;; higher arities and wider signals, may be introduced by the @(see multidrive)
;; transform to deal with multiply driven wires.</p>

;; <p>The corresponding @(see esim) primitive is @(see acl2::*esim-res*).</p>")

;; (defconsts *vl-1-bit-resolve-wire*
;;   (b* ((name "VL_1_BIT_RESOLVE_WIRE")
;;        (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
;;        ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
;;        ((mv a-expr   a-port   a-portdecl   a-netdecl)   (vl-primitive-mkport "a"   :vl-input))
;;        ((mv b-expr   b-port   b-portdecl   b-netdecl)   (vl-primitive-mkport "b"   :vl-input))
;;        (a-assign     (make-vl-assign :lvalue out-expr :expr a-expr :loc *vl-fakeloc*))
;;        (b-assign     (make-vl-assign :lvalue out-expr :expr b-expr :loc *vl-fakeloc*)))
;;     (make-honsed-vl-module :name      name
;;                            :origname  name
;;                            :ports     (list out-port     a-port      b-port)
;;                            :portdecls (list out-portdecl a-portdecl  b-portdecl)
;;                            :netdecls  (list out-netdecl  a-netdecl   b-netdecl)
;;                            :assigns   (list              a-assign    b-assign)
;;                            :minloc    *vl-fakeloc*
;;                            :maxloc    *vl-fakeloc*
;;                            :atts      atts
;;                            :esim      acl2::*esim-res*)))


(defconst *vl-primitive-mods*
  (list *vl-1-bit-t*
        *vl-1-bit-f*
        *vl-1-bit-x*
        *vl-1-bit-z*
        *vl-1-bit-power*
        *vl-1-bit-ground*
        *vl-1-bit-assign*
        *vl-1-bit-delay-1*
        *vl-1-bit-buf*
        *vl-1-bit-not*
        *vl-1-bit-and*
        *vl-1-bit-or*
        *vl-1-bit-xor*
        *vl-1-bit-nand*
        *vl-1-bit-nor*
        *vl-1-bit-xnor*
        *vl-1-bit-zmux*
        *vl-1-bit-ceq*
        *vl-1-bit-flop*
        *vl-1-bit-latch*

        *vl-1-bit-bufif0*
        *vl-1-bit-bufif1*
        *vl-1-bit-notif0*
        *vl-1-bit-notif1*
        *vl-1-bit-nmos*
        *vl-1-bit-rnmos*
        *vl-1-bit-pmos*
        *vl-1-bit-rpmos*
        *vl-1-bit-cmos*
        *vl-1-bit-rcmos*
        *vl-1-bit-tran*
        *vl-1-bit-rtran*
        *vl-1-bit-tranif0*
        *vl-1-bit-rtranif0*
        *vl-1-bit-tranif1*
        *vl-1-bit-rtranif1*
        *vl-1-bit-pullup*
        *vl-1-bit-pulldown*
        ;; *vl-1-bit-resolve-wire*
        ))





;; Commenting this out for now, until we implement WAND/WOR.

;; (defxdoc *vl-1-bit-resolve-wor* :parents (primitives) :short "Primitive
;;   module that resolves multiple drivers on a @('wor') net."  :long "<p>The
;;   Verilog definition of this module is:</p>

;; @({
;; module VL_1_BIT_RESOLVE_WOR (out, a, b) ;
;;   output out;
;;   input a;
;;   input b;

;;   wor out;

;;   assign out = a;
;;   assign out = b;
;; endmodule
;; })

;; <p>VL takes this as a primitive.  This module, and wrappers that extend it to
;; higher arities and wider signals, may be introduced by the @(see multidrive)
;; transform to deal with multiply driven wired ors.</p>")

;; (defconsts *vl-1-bit-resolve-wor*
;;   (b* ((name "VL_1_BIT_RESOLVE_WOR")
;;        (atts '(("VL_PRIMITIVE") ("VL_HANDS_OFF")))
;;        ((mv out-expr out-port out-portdecl out-netdecl) (vl-primitive-mkport "out" :vl-output))
;;        ((mv a-expr   a-port   a-portdecl   a-netdecl)   (vl-primitive-mkport "a"   :vl-input))
;;        ((mv b-expr   b-port   b-portdecl   b-netdecl)   (vl-primitive-mkport "b"   :vl-input))
;;        (out-netdecl  (change-vl-netdecl out-netdecl :type :vl-wor))
;;        (a-assign     (make-vl-assign :lvalue out-expr :expr a-expr :loc *vl-fakeloc*))
;;        (b-assign     (make-vl-assign :lvalue out-expr :expr b-expr :loc *vl-fakeloc*)))
;;     (make-honsed-vl-module :name      name
;;                            :origname  name
;;                            :ports     (list out-port     a-port      b-port)
;;                            :portdecls (list out-portdecl a-portdecl  b-portdecl)
;;                            :netdecls  (list out-netdecl  a-netdecl   b-netdecl)
;;                            :assigns   (list              a-assign    b-assign)
;;                            :minloc    *vl-fakeloc*
;;                            :maxloc    *vl-fakeloc*
;;                            :atts      atts)))




#||

(include-book ;; fool dependency scanner
 "mlib/writer")

(vl-pps-modulelist *vl-primitive-mods*)

||#