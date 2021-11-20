Require Import Coq.Lists.List.
Require Import Coq.Bool.Bool.
Require Import Poulet4.P4cub.Util.EquivUtil.
Import ListNotations.

Module FuncAsMap.

  Section FuncAsMap.

    Context {key: Type}.
    Context {key_eqb: key -> key -> bool}.
    Context {value: Type}.

    Definition t := key -> option value.

    Definition empty: t := fun _ => None.
    Definition get: key -> t -> option value := fun k fmap => fmap k.
    Definition set: key -> value -> t -> t :=
      fun k v fmap x => if key_eqb x k then Some v else fmap x.

    Definition sets: list key -> list value -> t -> t :=
      fun kList vList fmap =>
        fold_left (fun fM kvPair => set (fst kvPair) (snd kvPair) fM)
                  (combine kList vList) fmap.

    Definition gets (kl: list key) (m: t): list (option value) :=
      map (fun k => get k m) kl.
  End FuncAsMap.

  Section FuncMapMap.
    Context {key: Type} {key_eqb: key -> key -> bool} {U V : Type}.

    Section Map.
      Variable f : U -> V.
      
      Definition map_map (e : @t key U) : @t key V :=
        fun k => match e k with
            | Some u => Some (f u)
            | None   => None
              end.
    End Map.

    Section Rel.
      Variable R : U -> V -> Prop.

      Definition related (eu : @t key U) (ev : @t key V) : Prop :=
        forall k : key,
          relop R (get k eu) (get k ev).
    End Rel.
  End FuncMapMap.
End FuncAsMap.

Module IdentMap.

Section IdentMap.

Notation ident := String.string.
Context {A: Type}.

Definition t := @FuncAsMap.t ident A.
Definition empty : t := FuncAsMap.empty.
Definition get : ident -> t -> option A := FuncAsMap.get.
Definition set : ident -> A -> t -> t :=
  @FuncAsMap.set ident String.eqb A.
Definition sets: list ident -> list A -> t -> t :=
  @FuncAsMap.sets ident String.eqb A.
Definition gets: list ident -> t -> list (option A) := FuncAsMap.gets.

End IdentMap.

End IdentMap.

Definition list_eqb {A} (eqb : A -> A -> bool) al bl :=
  Nat.eqb (length al) (length bl) &&
  forallb (uncurry eqb) (combine al bl).

Definition path_equivb :
  (list String.string) -> (list String.string) -> bool :=
  list_eqb String.eqb.

Module PathMap.

Section PathMap.

Notation ident := String.string.
Notation path := (list ident).
Context {A: Type}.

Definition t := @FuncAsMap.t path A.
Definition empty : t := FuncAsMap.empty.
Definition get : path -> t -> option A := FuncAsMap.get.
Definition set : path -> A -> t -> t :=
  @FuncAsMap.set path path_equivb A.
Definition sets : list path -> list A -> t -> t :=
  @FuncAsMap.sets path path_equivb A.
Definition gets: list path -> t -> list (option A) := FuncAsMap.gets.

End PathMap.

End PathMap.

Arguments IdentMap.t _: clear implicits.
Arguments PathMap.t _: clear implicits.
