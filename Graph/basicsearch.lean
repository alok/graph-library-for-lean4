import Graph.graphrepresentation
import Std.Data.Queue
import Std.Data.Stack

namespace Std
namespace Stack

def pop? {α : Type} [Inhabited α] (s : Std.Stack α) : Option (α × (Std.Stack α)) := match s.peek? with
  | some element => (element, s.pop)
  | none => none

end Stack
end Std


namespace Graph

variable {α : Type} [BEq α] [Inhabited α]

universe u

structure Container (β : Type u) (containerType : Type u -> Type u) where -- TODO make private
  χ := containerType β
  container : χ
  addFun : β -> χ -> χ
  removeFun : χ -> Option (β × χ)

namespace Container

def add (cont : Container b c) (x : b) : Container b c := {
  cont with container := cont.addFun x cont.container
}

def remove? (cont : Container b c) : Option (b × (Container b c)) := match cont.removeFun cont.container with
  | some (element, containerWithoutElement) => 
    let newCont := { cont with container := containerWithoutElement }
    some (element, newCont)
  | none => none

def emptyStack [Inhabited α] : Container α Std.Stack := { container := Std.Stack.empty, addFun := Std.Stack.push, removeFun := Std.Stack.pop? }

end Container

-- Note: See test functions for Container at the end of this file


-- TODO make it generic stack - queue (tip: bundle them into a structure which is either stack or queue)
private def BFSAux (g : Graph α) (target : Nat) (visited : Array Bool) (q : Std.Queue Nat) : Nat -> Bool
  | 0 => false
  | n + 1 => do
    let mut queue : Std.Queue Nat := q
    let mut visitedMutable := visited
    match queue.dequeue? with
      | none => return false
      | some x =>
        let current := x.1
        queue := x.2
        for edge in g.vertices[current].adjacencyList do
          if !visited[edge.target] then
            if edge.target == target then return true
            visitedMutable := visitedMutable.set! edge.target true
            queue := queue.enqueue edge.target
        BFSAux g target visitedMutable queue n
    

def breadthFirstSearch (g : Graph α) (source : Nat) (target : Nat) : Bool := 
  if source == target then true
  else 
    let visited : Array Bool := mkArray g.vertices.size false
    let q : Std.Queue Nat := Std.Queue.empty
    BFSAux g target (visited.set! source true) (q.enqueue source) g.vertices.size

-- Stack
def containerTesting1 : Array Nat := do
  let mut container := Container.emptyStack
  container := container.add 1
  container := container.add 2
  container := container.add 3
  container := container.add 4
  container := container.add 5
  container := container.add 6
  container := container.add 7
  container := container.add 8

  let mut arr : Array Nat := #[]
  let mut e : Nat := arbitrary

  (e, container) := match container.remove? with
    | some x => x
    | none => (42, Container.emptyStack)
  arr := arr.push e
  (e, container) := match container.remove? with
    | some x => x
    | none => (42, Container.emptyStack)
  arr := arr.push e
  (e, container) := match container.remove? with
    | some x => x
    | none => (42, Container.emptyStack)
  arr := arr.push e
  (e, container) := match container.remove? with
    | some x => x
    | none => (42, Container.emptyStack)
  arr := arr.push e
  (e, container) := match container.remove? with
    | some x => x
    | none => (42, Container.emptyStack)
  arr := arr.push e
  (e, container) := match container.remove? with
    | some x => x
    | none => (42, Container.emptyStack)
  arr := arr.push e
  (e, container) := match container.remove? with
    | some x => x
    | none => (42, Container.emptyStack)
  arr := arr.push e
  (e, container) := match container.remove? with
    | some x => x
    | none => (42, Container.emptyStack)
  arr := arr.push e

  arr

def containerTesting2 : Nat := do
  let mut container : Container Nat Std.Stack := { container := Std.Stack.empty, addFun := Std.Stack.push, removeFun := Std.Stack.pop, getFun := Std.Stack.peek! }
  container := container.add 3
  container := container.add 4
  container := container.add 5
  container := container.add 6
  container := container.add 7
  container := container.add 8
  container := container.remove
  container := container.remove
  container.get


-- Queue
def containerTesting3 : Array Nat := do
  let mut arr : Array Nat := #[]
  let mut container : Container Nat Std.Queue := { container := Std.Queue.empty, addFun := Std.Queue.enqueue, removeFun := Std.Queue.dequeue!, getFun := Std.Queue.peek! }
  container := container.add 1
  container := container.add 2
  container := container.add 3
  container := container.add 4
  container := container.add 5
  container := container.add 6
  container := container.add 7
  container := container.add 8
  arr := arr.push container.get
  container := container.remove
  arr := arr.push container.get
  container := container.remove
  arr := arr.push container.get
  container := container.remove
  arr := arr.push container.get
  container := container.remove
  arr := arr.push container.get
  container := container.remove
  arr := arr.push container.get
  container := container.remove
  arr := arr.push container.get
  container := container.remove
  arr := arr.push container.get
  container := container.remove
  arr

def containerTesting4 : Nat := do
  let mut container : Container Nat Std.Queue := { container := Std.Queue.empty, addFun := Std.Queue.enqueue, removeFun := Std.Queue.dequeue!, getFun := Std.Queue.peek! }
  container := container.add 3
  container := container.add 4
  container := container.add 5
  container := container.add 6
  container := container.add 7
  container := container.add 8
  container := container.remove
  -- container := container.remove
  container.get
  

end Graph