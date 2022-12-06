Require Import Coq.ZArith.BinInt
  Poulet4.P4cub.Syntax.CubNotations
  Poulet4.P4light.Architecture.Target
  Poulet4.P4light.Syntax.Syntax
  RecordUpdate.RecordSet.
From Poulet4.P4cub.Semantics.Dynamic Require Import
     BigStep.Value.Value.
From Poulet4.P4cub.Semantics.Dynamic Require Export
  BigStep.ExprUtil BigStep.ValEnvUtil BigStep.InstUtil
  BigStep.Value.Embed.
Import Val.ValueNotations ExprNotations ParserNotations
  Val.LValueNotations StmtNotations RecordSetNotations.

(** * Expression evaluation. *)

Reserved Notation "⟨ ϵ , e ⟩ ⇓ v"
         (at level 80, no associativity).

Local Open Scope value_scope.
Local Open Scope expr_scope.

Inductive expr_big_step (ϵ : list Val.v)
  : Expr.e -> Val.v -> Prop :=
| ebs_bool (b : bool) :
  ⟨ ϵ, b ⟩ ⇓ b
| ebs_bit w n :
  ⟨ ϵ, w `W n ⟩ ⇓ w VW n
| ebs_int w z :
  ⟨ ϵ, w `S z ⟩ ⇓ w VS z
| ebs_varbit m w n :
  ⟨ ϵ, Expr.VarBit m w n ⟩ ⇓ Val.VarBit m w n
| ebs_var τ og x v :
  nth_error ϵ x = Some v ->
  ⟨ ϵ, Expr.Var τ og x ⟩ ⇓ v
| ebs_slice e hi lo v v' :
  slice_val hi lo v = Some v' ->
  ⟨ ϵ, e ⟩ ⇓ v ->
  ⟨ ϵ, Expr.Slice hi lo e ⟩ ⇓ v'
| ebs_cast τ e v v' :
  eval_cast τ v = Some v' ->
  ⟨ ϵ, e ⟩ ⇓ v ->
  ⟨ ϵ, Expr.Cast τ e ⟩ ⇓ v'
| ebs_error err :
  ⟨ ϵ, Expr.Error err ⟩ ⇓ Val.Error err
| ebs_uop τ op e v v' :
  eval_uop op v = Some v' ->
  ⟨ ϵ, e ⟩ ⇓ v ->
  ⟨ ϵ, Expr.Uop τ op e ⟩ ⇓ v'
| ebs_bop τ op e₁ e₂ v v₁ v₂ :
  eval_bop op v₁ v₂ = Some v ->
  ⟨ ϵ, e₁ ⟩ ⇓ v₁ ->
  ⟨ ϵ, e₂ ⟩ ⇓ v₂ ->
  ⟨ ϵ, Expr.Bop τ op e₁ e₂ ⟩ ⇓ v
| ebs_member τ x e ls vs v :
  nth_error vs x = Some v ->
  ⟨ ϵ, e ⟩ ⇓ Val.Lists ls vs ->
  ⟨ ϵ, Expr.Member τ x e ⟩ ⇓ v
| ebs_index τ e₁ e₂ ls vs w n v :
  nth_error vs (Z.to_nat n) = Some v ->
  ⟨ ϵ, e₁ ⟩ ⇓ Val.Lists ls vs ->
  ⟨ ϵ, e₂ ⟩ ⇓ w VW n ->
  ⟨ ϵ, Expr.Index τ e₁ e₂ ⟩ ⇓ v
| ebs_lists ls es vs :
  Forall2 (expr_big_step ϵ) es vs ->
  ⟨ ϵ, Expr.Lists ls es ⟩ ⇓ Val.Lists ls vs
where "⟨ ϵ , e ⟩ ⇓ v"
  := (expr_big_step ϵ e v) : type_scope.

Local Open Scope lvalue_scope.

(** L-expression evaluation. *)

Reserved Notation "'l⟨' ϵ , e ⟩ '⇓' lv" (at level 80, no associativity).

Inductive lexpr_big_step (ϵ : list Val.v) : Expr.e -> Val.lv -> Prop :=
| lebs_var τ og x :
  l⟨ ϵ, Expr.Var τ og x ⟩ ⇓ Val.Var x
| lebs_slice hi lo e lv :
  l⟨ ϵ, e ⟩ ⇓ lv ->
  l⟨ ϵ, Expr.Slice hi lo e ⟩ ⇓ Val.Slice hi lo lv
| lebs_member τ x e lv :
  l⟨ ϵ, e ⟩ ⇓ lv ->
  l⟨ ϵ, Expr.Member τ x e ⟩ ⇓ lv DOT x
| lebs_index τ e₁ e₂ lv w n :
  ⟨ ϵ, e₂ ⟩ ⇓ (w VW n)%value ->
  l⟨ ϵ, e₁ ⟩ ⇓ lv ->
  l⟨ ϵ, Expr.Index τ e₁ e₂ ⟩ ⇓ Val.Index (Z.to_N n) lv
where "'l⟨' ϵ , e ⟩ '⇓' lv"
  := (lexpr_big_step ϵ e lv) : type_scope.

Local Close Scope expr_scope.
Local Close Scope lvalue_scope.

(** Parser-expression evaluation. *)

Reserved Notation "'p⟨' ϵ , e ⟩ ⇓ st" (at level 80, no associativity).

Variant parser_expr_big_step (ϵ : list Val.v)
  : Parser.pt -> Parser.state_label -> Prop :=
  | pebs_goto st :
    p⟨ ϵ, Parser.Direct st ⟩ ⇓ st
  | pebs_select e default cases v :
    ⟨ ϵ, e ⟩ ⇓ v ->
    p⟨ ϵ, Parser.Select e default cases ⟩
       ⇓ match Field.find_value (fun p => match_pattern p v) cases with
         | Some st => st
         | None    => default
         end
where "'p⟨' ϵ , e ⟩ ⇓ st"
  := (parser_expr_big_step ϵ e st) : type_scope.

(** * Statement evaluation. *)

(** Statement signals. *)
Variant signal : Set :=
  | Cont                    (** continue *)
  | Exit                    (** exit *)
  | Acpt                    (** parser accept *)
  | Rjct                    (** parser reject *)       
  | Rtrn (v : option Val.v) (** return *).

Variant parser_signal : signal -> signal -> Prop :=
| parser_acpt_cont : parser_signal Acpt Cont
| parser_rjct_rjct : parser_signal Rjct Rjct
| parser_exit_exit : parser_signal Exit Exit.

(** Evidence that control-flow
      is interrupted by an exit or return statement. *)
Variant interrupt : signal -> Prop :=
| interrupt_exit    : interrupt Exit
| interrupt_rtrn vo : interrupt (Rtrn vo)
| interrupt_rjct    : interrupt Rjct.

(** A final parser state. *)
Variant final_state : Parser.state_label -> signal -> Prop :=
  | final_accept : final_state Parser.Accept Acpt
  | final_reject : final_state Parser.Reject Rjct.

(** An intermediate parser state. *)
Variant intermediate_state : Parser.state_label -> Prop :=
  | intermediate_start  : intermediate_state Parser.Start
  | intermediate_name x : intermediate_state (Parser.Name x).

(** Context for statement evaluation.
    Syntactically where a statement
    occurs within a program
    determines which environments
    are available to it. *)
Variant ctx : Set :=
  | CAction
      (available_actions : aenv)
  | CFunction
  | CApplyBlock
      (tables : tenv)
      (available_actions : aenv)
      (available_controls : inst_env)
  | CParserState
      (parser_arg_length : nat)
      (start : Stmt.s)
      (states : list Stmt.s)
      (available_parsers : inst_env).

(** Fetch the next state-block to evaluate. *)
Definition get_state_block
           (strt : Stmt.s)
           (states : list Stmt.s)
           (next : Parser.state_label) : option Stmt.s :=
  match next with
  | Parser.Start  => Some strt
  | Parser.Name x => nth_error states x
  | _             => None
  end.

Local Open Scope stmt_scope.

Definition lv_update_signal
           (olv : option Val.lv) (sig : signal)
           (ϵ : list Val.v) : list Val.v :=
  match olv, sig with
  | Some lv, Rtrn (Some v) => lv_update lv v ϵ
  | _ , _ => ϵ
  end.

Notation light_set := (@ValueSet unit).

Open Scope pat_scope.

(* TODO: cast case. *)
Variant pre_match_big_step : @MatchPreT unit -> Parser.pat -> Prop :=
  | bs_DontCare :
    pre_match_big_step MatchDontCare Parser.Wild
  | bs_Mask l₁ l₂ e₁ e₂ n₁ n₂ w :
    embed_expr e₁ l₁ ->
    embed_expr e₂ l₂ ->
    ⟨ [], e₁ ⟩ ⇓ w VW n₁ ->
    ⟨ [], e₂ ⟩ ⇓ w VW n₂ ->
    pre_match_big_step (MatchMask l₁ l₂) (Parser.Mask (w PW n₁) (w PW n₂))
  | bs_Range l₁ l₂ e₁ e₂ n₁ n₂ w :
    embed_expr e₁ l₁ ->
    embed_expr e₂ l₂ ->
    ⟨ [], e₁ ⟩ ⇓ w VW n₁ ->
    ⟨ [], e₂ ⟩ ⇓ w VW n₂ ->
    pre_match_big_step (MatchMask l₁ l₂) (Parser.Range (w PW n₁) (w PW n₂)).

Close Scope pat_scope.

Variant match_big_step : @Match unit -> Parser.pat -> Prop :=
  | bs_MkMatch τ m p :
    pre_match_big_step m p -> match_big_step (MkMatch tt m τ) p.

Variant table_entry_big_step
  : table_entry (tags_t:=unit) (Expression:=Expr.e) -> Parser.pat -> action_ref -> Prop :=
  | bs_mk_table_entry mtchs pats aref :
    Forall2 match_big_step mtchs pats ->
    table_entry_big_step (mk_table_entry mtchs aref) (Parser.Lists pats) aref.

Notation Extern_Sem := (ExternSem (tags_t:=unit) (Expression:=Expr.e)).

Section StmtEvalEnv.
  Variable ext_sem : Extern_Sem.
  
  Record stmt_eval_env : Type :=
    mk_stmt_eval_env {
        functs : fenv (** function closure. *) ;
        extrn_env   : extern_env (** extern environment. *);
        extrn_state : extern_state (** extern state. *) }.
  
  Global Instance eta_stmt_eval_env : Settable _
    := settable! mk_stmt_eval_env <functs; extrn_env; extrn_state>.
End StmtEvalEnv.

Arguments functs {_}.
Arguments extrn_env {_}.
Arguments extrn_state {_}.
Arguments eta_stmt_eval_env {_}.

(** Statement evaluation :
    Given a statement evaluation environment [Ψ]
    and a De Bruijn value environment [ϵ],
    a syntactic context [c],
    a statement [s] is evaluated to
    a new value environment [ϵ'],
    a signal [sig], and a new extern state [ψ]. *)
Reserved Notation "⧼ Ψ , ϵ , c , s ⧽ ⤋ ⧼ ϵ' , sig , ψ ⧽"
         (at level 80, no associativity).

Definition copy_out_from_arg
  (input_arg : paramarg Val.v Val.lv) (output_arg : paramarg Val.v Val.v)
  (ϵ_call : list Val.v) : list Val.v :=
  match input_arg, output_arg with
  | PAOut lv, PAOut v
  | PAInOut lv, PAInOut v => lv_update lv v ϵ_call
  | _, _ => ϵ_call
  end.

Fixpoint copy_out_from_args
  (input_args : Val.argsv) (output_args : list (paramarg Val.v Val.v))
  (ϵ_call : list Val.v) : list Val.v :=
  match input_args, output_args with
  | i :: iargs, o :: oargs => copy_out_from_args iargs oargs (copy_out_from_arg i o ϵ_call)
  | _, _ => ϵ_call
  end.

Definition arg_big_step (ϵ : list Val.v) : Expr.arg -> Val.argv -> Prop :=
  rel_paramarg
    (expr_big_step ϵ)
    (lexpr_big_step ϵ).

Definition args_big_step (ϵ : list Val.v) : Expr.args -> Val.argsv -> Prop :=
  Forall2 (arg_big_step ϵ).

Inductive stmt_big_step
  `{ext_sem : Extern_Sem} (Ψ : stmt_eval_env ext_sem)
  : list Val.v -> ctx -> Stmt.s -> list Val.v -> signal
    -> extern_state (tags_t:=unit) (Expression:=Expr.e) -> Prop :=
| sbs_skip ϵ c :
  ⧼ Ψ, ϵ, c, Stmt.Skip ⧽ ⤋ ⧼ ϵ, Cont, extrn_state Ψ ⧽
| sbs_exit ϵ c :
  ⧼ Ψ, ϵ, c, Stmt.Exit ⧽ ⤋ ⧼ ϵ, Exit, extrn_state Ψ ⧽
| sbs_return ϵ c eo vo :
  relop (expr_big_step ϵ) eo vo ->
  ⧼ Ψ, ϵ, c, Stmt.Return eo ⧽ ⤋ ⧼ ϵ, Rtrn vo, extrn_state Ψ ⧽
| sbs_transition_final
    ϵ trns n start states parsers lbl sig :
  final_state lbl sig ->
  p⟨ ϵ, trns ⟩ ⇓ lbl ->
  ⧼ Ψ, ϵ, CParserState n start states parsers,
    Stmt.Transition trns ⧽ ⤋ ⧼ ϵ, sig, extrn_state Ψ ⧽
| sbs_transition_intermediate
    ϵ₁ ϵ₂ ϵ₃ trns start states parsers ψ lbl sig state :
  get_state_block start states lbl = Some state ->
  intermediate_state lbl ->
  p⟨ ϵ₁ ++ ϵ₂, trns ⟩ ⇓ lbl ->
  ⧼ Ψ, ϵ₂, CParserState (length ϵ₂) start states parsers, state ⧽ ⤋ ⧼ ϵ₃, sig, ψ ⧽ ->
  ⧼ Ψ, ϵ₁ ++ ϵ₂, CParserState (length ϵ₂) start states parsers,
    Stmt.Transition trns ⧽ ⤋ ⧼ ϵ₁ ++ ϵ₃, sig, ψ ⧽
| sbs_assign ϵ c e₁ e₂ lv v :
  l⟨ ϵ, e₁ ⟩ ⇓ lv ->
  ⟨ ϵ, e₂ ⟩ ⇓ v ->
  ⧼ Ψ, ϵ, c, e₁ `:= e₂ ⧽ ⤋ ⧼ lv_update lv v ϵ, Cont, extrn_state Ψ ⧽
| sbs_funct_call
    ϵ ϵ' ϵ'' c ψ f τs args
    eo vargs olv fun_clos body sig :
  functs Ψ f = Some (FDecl fun_clos body) ->
  (** Evaluate l-expression. *)
  relop (lexpr_big_step ϵ) eo olv ->
  (** Evaluate arguments. *)
  args_big_step ϵ args vargs ->
  (** Copyin. *)
  copy_in vargs ϵ = Some ϵ' ->
  (** Evaluate the function body. *)
  ⧼ Ψ <| functs := fun_clos |>, ϵ', CFunction,
      tsub_s (gen_tsub τs) body ⧽ ⤋ ⧼ ϵ'', sig, ψ ⧽ ->
  ⧼ Ψ, ϵ, c, Stmt.Call (Stmt.Funct f τs eo) args ⧽
    ⤋ ⧼ lv_update_signal olv sig (copy_out vargs ϵ'' ϵ), Cont, ψ ⧽  
| sbs_action_call
    ϵ ϵ' ϵ'' clos c ψ a ctrl_args data_args actions
    vctrl_args vdata_args olv fun_clos act_clos body sig :
  match c with
  | CAction actions
  | CApplyBlock _ actions _ => Some actions
  | _ => None
  end = Some actions ->
  (** Lookup action. *)
  actions a = Some (ADecl clos fun_clos act_clos body) ->
  (** Evaluate control-plane arguments. *)
  Forall2 (expr_big_step ϵ) ctrl_args vctrl_args ->
  (** Evaluate data-plane arguments. *)
  args_big_step ϵ data_args vdata_args ->
  (** Copyin. *)
  copy_in vdata_args clos = Some ϵ' ->
  (** Evaluate the action body. *)
  ⧼ Ψ <| functs := fun_clos |>, vctrl_args ++ ϵ', CAction act_clos,
      body ⧽ ⤋ ⧼ ϵ'', sig, ψ ⧽ ->
  ⧼ Ψ, ϵ, c, Stmt.Call (Stmt.Action a ctrl_args) data_args ⧽
    ⤋ ⧼ lv_update_signal olv sig (copy_out vdata_args ϵ'' ϵ), Cont, ψ ⧽
| sbs_method_call
    ϵ c ψ ext meth τs args
    eo vargs vargs' olv sig
    light_typs light_in_vals light_out_vals light_sig :
  (** Invariant for cub arguments. *)
  Forall2
    (rel_paramarg eq (fun _ _ => True))
    vargs vargs' ->
  (** Evaluate l-expression. *)
  relop (lexpr_big_step ϵ) eo olv ->
  (** Evaluate arguments. *)
  args_big_step ϵ args vargs ->
  (** Embed type arguments in p4light. *)
  Forall2 (P4Cub_to_P4Light (dummy_tags:=tt) (string_list:=[])) τs light_typs ->
  (** Embed in-arguments in p4light. *)
  Forall2
    Embed
    (List.flat_map
       (fun v => match v with PAIn v => [v] | _ => [] end)
       vargs) light_in_vals ->
  (** Evaluate the extern. *)
  exec_extern
    (extrn_env Ψ) (extrn_state Ψ)
    ext meth [] light_typs light_in_vals ψ light_out_vals light_sig ->
  (** Out-values back to p4cub. *)
  Forall2
    Embed
    (List.flat_map
       (fun v => match v with PAOut v | PAInOut v => [v] | _ => [] end)
       vargs') light_out_vals ->
  ⧼ Ψ, ϵ, c, Stmt.Call (Stmt.Method ext meth τs eo) args ⧽
    ⤋ ⧼ lv_update_signal olv sig (copy_out_from_args vargs vargs' ϵ), Cont, ψ ⧽
| sbs_invoke
    ϵ₁ ϵ₂ ϵ' t (tbls : tenv) acts insts pats light_sets
    ψ (key : list (Expr.e * string)) actions vs light_vals arefs
    a opt_ctrl_args ctrl_args data_args :
  (** Lookup table. *)
  tbls t = Some (length ϵ₂, key, actions) ->
  (** Evaluate table key. *)
  Forall2 (expr_big_step ϵ₂) (map fst key) vs ->
  (** Evaluate table entries. *)
  Forall3 table_entry_big_step (extern_get_entries ψ []) pats arefs ->
  (** Embed p4cub patterns in p4light value sets. *)
  Forall2 embed_pat_valset pats light_sets ->
  (** Get action reference from control-plane with control-plane arguments. *)
  extern_match (combine light_vals (map snd key)) (combine light_sets arefs)
  = Some (mk_action_ref a opt_ctrl_args) ->
  (** Find appropriate action data-plane arguments in table. *)
  Field.get a actions = Some data_args ->
  (** Force control-plane arguments to be defined. *)
  Forall2 (fun oe e => oe = Some e) opt_ctrl_args ctrl_args ->
  (** Evaluate action. *)
  ⧼ Ψ, ϵ₂, CApplyBlock tbls acts insts,
    Stmt.Call (Stmt.Action a ctrl_args) data_args ⧽ ⤋ ⧼ ϵ', Cont, ψ ⧽ ->
  ⧼ Ψ, ϵ₁ ++ ϵ₂, CApplyBlock tbls acts insts,
    Stmt.Invoke t ⧽ ⤋ ⧼ ϵ₁ ++ ϵ', Cont, ψ ⧽
| sbs_apply_control
    ϵ ϵ' ϵ'' tbls actions control_insts
    c ext_args args vargs sig ψ
    fun_clos inst_clos tbl_clos action_clos apply_block :
  (** Lookup control instance. *)
  control_insts c
  = Some (ControlInst
            fun_clos inst_clos tbl_clos
            action_clos apply_block) ->
  (** Evaluate arguments. *)
  args_big_step ϵ args vargs ->
  (** Copyin. *)
  copy_in vargs ϵ = Some ϵ' ->
  (** Evaluate control apply block. *)
  ⧼ Ψ <| functs := fun_clos |>, ϵ', CApplyBlock tbl_clos action_clos inst_clos,
      apply_block ⧽ ⤋ ⧼ ϵ'', sig, ψ ⧽ ->
  ⧼ Ψ, ϵ, CApplyBlock tbls actions control_insts,
    Stmt.Apply c ext_args args ⧽ ⤋ ⧼ copy_out vargs ϵ'' ϵ, Cont, ψ ⧽
| sbs_apply_parser
    ϵ ϵ' ϵ'' n strt states parsers ψ p
    ext_args args vargs
    fun_clos prsr_clos strt_clos states_clos final sig :
  (** Lookup parser instance. *)
  parsers p = Some (ParserInst fun_clos prsr_clos strt states) ->
  (** Evaluate arguments. *)
  args_big_step ϵ args vargs ->
  (** Copyin. *)
  copy_in vargs ϵ = Some ϵ' ->
  parser_signal final sig ->
  (** Evaluate parser state machine. *)
  ⧼ Ψ <| functs := fun_clos |>, ϵ',
      CParserState (length args) strt_clos states_clos prsr_clos,
      strt ⧽ ⤋ ⧼ ϵ'', final, ψ ⧽ ->
  ⧼ Ψ, ϵ, CParserState n strt states parsers,
    Stmt.Apply p ext_args args ⧽ ⤋ ⧼ copy_out vargs ϵ'' ϵ, sig, ψ ⧽
| sbs_var ϵ ϵ' c og te v v' s sig ψ :
  match te with
  | inr e => ⟨ ϵ, e ⟩ ⇓ v
  | inl τ => v_of_t τ = Some v
  end ->
  ⧼ Ψ, v :: ϵ, c, s ⧽ ⤋ ⧼ v' :: ϵ', sig, ψ ⧽ ->
  ⧼ Ψ, ϵ, c, Stmt.Var og te s ⧽ ⤋ ⧼ ϵ', sig, ψ ⧽
| sbs_seq_cont ϵ ϵ' ϵ'' c s₁ s₂ sig ψ ψ' :
  ⧼ Ψ, ϵ, c, s₁ ⧽ ⤋ ⧼ ϵ', Cont, ψ ⧽ ->
  ⧼ Ψ <| extrn_state := ψ |>, ϵ', c, s₂ ⧽ ⤋ ⧼ ϵ'', sig, ψ' ⧽ ->
  ⧼ Ψ, ϵ, c, s₁ `; s₂ ⧽ ⤋ ⧼ ϵ'', sig, ψ' ⧽
| sbs_seq_interrupt ϵ ϵ' c s₁ s₂ sig ψ :
  interrupt sig ->
  ⧼ Ψ, ϵ, c, s₁ ⧽ ⤋ ⧼ ϵ', sig, ψ ⧽ ->
  ⧼ Ψ, ϵ, c, s₁ `; s₂ ⧽ ⤋ ⧼ ϵ', sig, ψ ⧽
| sbs_cond ϵ ϵ' c e s₁ s₂ (b : bool) sig ψ :
  ⟨ ϵ, e ⟩ ⇓ b ->
  ⧼ Ψ, ϵ, c, if b then s₁ else s₂ ⧽ ⤋ ⧼ ϵ', sig, ψ ⧽ ->
  ⧼ Ψ, ϵ, c, If e Then s₁ Else s₂ ⧽ ⤋ ⧼ ϵ', sig, ψ ⧽
where "⧼ Ψ , ϵ , c , s ⧽ ⤋ ⧼ ϵ' , sig , ψ ⧽"
  := (stmt_big_step Ψ ϵ c s ϵ' sig ψ) : type_scope.

Local Close Scope stmt_scope.
Local Close Scope value_scope.
