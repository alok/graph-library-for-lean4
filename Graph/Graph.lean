structure Edge (β : Type) where
  target : Nat
  weight : β

structure Vertex (α : Type) (β : Type) where
  payload : α
  adjacencyList : Array (Edge β) := #[]

instance [Inhabited α] : Inhabited (Vertex α β) := ⟨ { payload := arbitrary } ⟩

structure Graph (α : Type) (β : Type) where
  vertices : Array (Vertex α β) := #[]

namespace Graph

variable {α : Type} [BEq α] [Inhabited α] {β : Type}

/-- Empty graph, α is the vertex payload type, β is edge weight type. -/
def empty : Graph α β := ⟨#[]⟩

/-- Add a vertex to the graph.
    Returns new graph and unique vertex ID. -/
def addVertex (g : Graph α β) (payload : α) : (Graph α β) × Nat :=
  let res := { g with vertices := g.vertices.push { payload := payload } }
  let id : Nat := res.vertices.size - 1
  (res, id)

class DefaultEdgeWeight (β : Type) where -- TODO remove this
  default : β

/-- -/
def addEdgeById [DefaultEdgeWeight β] (g : Graph α β) (source : Nat) (target : Nat) (weight : β := DefaultEdgeWeight.default) : Graph α β := {
  g with vertices := g.vertices.modify source (fun vertex => { vertex with adjacencyList := vertex.adjacencyList.push {target := target, weight := weight} })
}

/-- -/
def getVertexPayload (g : Graph α β) (id : Nat) : α := g.vertices[id].payload

/-- Removes all edges from source to target with specific weight.
    If weight is not specified all edges from source to target are removed. -/
def removeAllEdgesFromTo [BEq β] (g : Graph α β) (source : Nat) (target : Nat) (weight : Option β := none) : Graph α β := {
  g with vertices := g.vertices.modify source (λ vertex => { vertex with adjacencyList := vertex.adjacencyList.filter (λ edge =>
    match weight with
    | some w => (edge.weight != w) || edge.target != target
    | none => edge.target != target
  )})
}

/-- Removes all edges from the entire graph -/
def removeAllEdges (g : Graph α β) : Graph α β := {
  g with vertices := g.vertices.map (λ vertex => { vertex with adjacencyList := Array.empty })
}

/-- -/
def updateVertexPayload (g : Graph α β) (id : Nat) (payload : α) : Graph α β := {
  g with vertices := g.vertices.modify id (fun vertex => { vertex with payload := payload })
}

/-- Warning! This function is deprecated, vertex IDs will change if used.
    Returns graph without vertex and a mapping from old vertex IDs to new vertex IDs. -/
def removeVertex (g : Graph α β) (id : Nat) : (Graph α β) × (Nat -> Nat) :=
  let mapping : Nat -> Nat := mappingBase id
  let verticesWithEdgesRemoved := g.vertices.map (λ vertex => {
    vertex with adjacencyList := vertex.adjacencyList.filter (λ edge => edge.target != id)
  })
  let verticesWithMapping := verticesWithEdgesRemoved.map (λ vertex => {
    vertex with adjacencyList := vertex.adjacencyList.map (λ edge => {
      edge with target := mapping edge.target
    })
  })
  let verticesWithVertexRemoved := verticesWithMapping.eraseIdx id
  (⟨ verticesWithVertexRemoved ⟩, mapping)
  where
    mappingBase (id : Nat) (x : Nat) : Nat := if x > id then x - 1 else x

namespace Vertex

private def toString [ToString α] [ToString β] (v : Vertex α β) : String := "\nVertex payload: " ++ ToString.toString v.payload ++ ", edges:\n" ++ v.adjacencyList.foldr foldEdges "" ++ "\n"
  where foldEdges (e : Edge β) (s : String) : String :=
    s ++ "   target: " ++ (ToString.toString e.target) ++ ", weight: " ++ (ToString.toString e.weight) ++ "\n"

instance [ToString α] [ToString β] : ToString (Vertex α β) where toString := toString

end Vertex

instance [ToString α] [ToString β] : ToString (Graph α β) where toString g := do
  let mut indices : Array Nat := Array.empty
  for i in [0:g.vertices.size] do indices := indices.push i
  toString (indices.zip g.vertices)

end Graph




-- def findVertexId (g : Graph α β) (payload : α) : Option Nat := g.vertices.findIdx? (fun v => v.payload == payload) -- TODO