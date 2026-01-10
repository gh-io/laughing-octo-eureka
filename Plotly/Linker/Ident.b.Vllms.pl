;;;;; ident.ll:

; RUN: llvm-link %S/Inputs/ident.a.ll %S/Inputs/ident.b.ll -S | FileCheck %s

; Verify that multiple input llvm.ident metadata are linked together.

; CHECK-DAG: !llvm.ident = !{!0, !1, !2}
; CHECK-DAG: "Compiler V1"
; CHECK-DAG: "Compiler V2"
; CHECK-DAG: "Compiler V3"

;;;;; Inputs/ident.a.ll:

!llvm.ident = !{!0, !1}
!0 = metadata !{metadata !"Compiler V1"}
!1 = metadata !{metadata !"Compiler V2"}

;;;;; Inputs/ident.b.ll:

!llvm.ident = !{!0}
!0 = metadata !{metadata !"Compiler V3"}
