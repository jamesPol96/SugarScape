import java.util.List;
import java.util.Stack;

class SocialNetwork {
  boolean[][] adjMatrix;
  Dictionary<Agent, Dictionary<Agent, Integer>> adjDict; // agent a sees agents in adjDict.get(a)
  Dictionary<Agent, Dictionary<Agent, Integer>> reverseAdjDict; // agent b is seen by agents in adjDict.get(b)
  ArrayList<SocialNetworkNode> nodes;

  /** Initializes a new social network such that 
   *  for every pair of Agents (x,y) on grid g, 
   *   if x can see y (i.e. y is on a square that is in the vision of x), 
   *   then there is a directed edge from the SocialNetworkNode for x to 
   *   the SocialNetworkNode for y in this new social network. 
   *
   *  Note that x might be able to see y even if y cannot see x.
   */
  public SocialNetwork(SugarGrid g) {
    nodes = new ArrayList<SocialNetworkNode>();
    for (Agent a : g.getAgents())
      nodes.add(new SocialNetworkNode(a));
    adjDict = new ArrayDictionary<Agent, Dictionary<Agent, Integer>>();
    reverseAdjDict = new ArrayDictionary<Agent, Dictionary<Agent, Integer>>();
    for (int i = 0; i < nodes.size(); i++) {
      Agent current = nodes.get(i).getAgent();
      adjDict.put(current, new ArrayDictionary<Agent, Integer>());
      reverseAdjDict.put(current, new ArrayDictionary<Agent, Integer>());
    }
    for (int i = 0; i < nodes.size(); i++) {
      Agent current = nodes.get(i).getAgent();
      for (int j = 0; j < nodes.size(); j++) {
        Agent other = nodes.get(j).getAgent();
        if (i != j && canSee(current, other, g)) {
          adjDict.get(current).put(other, 1);
          reverseAdjDict.get(other).put(current, 1);
        }
      }
    }
  }

  /** Returns true if a can see b.
   *  causes an assertion failure if a is not in the Grid
   */
  private boolean canSee(Agent a, Agent b, SugarGrid g) {
    for (int i = 0; i < g.getWidth(); i++)
      for (int j = 0; j < g.getHeight(); j++)
        if (g.getAgentAt(i, j) == a) {
          return visible(b, g.generateVision(i, j, a.getVision()));
        }
    assert(1==0);
    return false; //shouldn't happen, if a is actually in g.
  }

  /** Returns true if one of visibleSquares contains the agent.
   */
  private boolean visible(Agent b, LinkedList<Square> visibleSquares) {
    for (Square s : visibleSquares) {
      if (s.getAgent() == b)
        return true;
    }
    return false;
  }

  /** Returns true if node n is adjacent to node m in this SocialNetwork. 
   *  (This means n's agent can see m's agent.)
   *  Returns false if either n or m is not present in the social network.
   */
  public boolean adjacent(SocialNetworkNode n, SocialNetworkNode m) {
    if (!nodes.contains(n) || !nodes.contains(m))
      return false;
    return adjDict.get(n.getAgent()).containsKey(m.getAgent());
  }

  /** Returns a list (either ArrayList or LinkedList) containing 
   *  all the nodes that n is adjacent to. (Those nodes whose agents are seen by n's agent.) 
   *  Returns null if n is not in the social network.
   */
  public List<SocialNetworkNode> seenBy(SocialNetworkNode n) {
    if (!adjDict.containsKey(n.getAgent()))
      return null;
    ArrayList<SocialNetworkNode> al = new ArrayList<SocialNetworkNode>();
    for (Agent a : adjDict.keySet()) {
      al.add(a.getSNNode());
    }
    return al;
  }

  /** Returns a list (either ArrayList or LinkedList) containing 
   *  all the nodes that are adjacent to m. (Those nodes whose agents see m's agent.) 
   *  Returns null if n is not in the social network.
   */
  public List<SocialNetworkNode> sees(SocialNetworkNode m) {
    if (!adjDict.containsKey(m.getAgent()))
      return null;
    ArrayList<SocialNetworkNode> al = new ArrayList<SocialNetworkNode>();
    for (Agent a : reverseAdjDict.keySet()) {
      al.add(a.getSNNode());
    }
    return al;
  }  

  /** Remove breadcrumbs from all nodes in the network.
   */
  public void removeBreadcrumbs() {
    for (SocialNetworkNode n : nodes)
      n.removeBreadcrumb();
  }

  /** Returns the node attached to the agent. 
   *  Asserts that the return value is not null; when the network was created all agents got nodes
   */
  private SocialNetworkNode getNode(Agent a) {
    assert(a.getSNNode() != null);
    return a.getSNNode();
  } 

  /** Returns true if there exists any path through the social network 
   *  that connects x to y. 
   *  A path should start at the node for agent x, 
   *  proceed through any node x can see, 
   *  and then any node that agent can see, and so on, 
   *  until it reaches node y.
   */
  public boolean pathExists(Agent a, Agent b) {
    SocialNetworkNode origin = getNode(a);
    SocialNetworkNode dest = getNode(b);
    if (origin == null || dest == null)
      return false;
    if (a == b)
      return true;
    removeBreadcrumbs();
    Stack<SocialNetworkNode> dfsStack = new Stack<SocialNetworkNode>();   
    dfsStack.push(origin);
    origin.placeBreadcrumb();
    while (!dfsStack.isEmpty()) {
      SocialNetworkNode n = dfsStack.pop();
      if (n == dest)
        return true;
      for (Agent c : adjDict.get(n.getAgent()).keySet()) {
        SocialNetworkNode m = c.getSNNode();
        if (!m.hasBreadcrumb()) {
          dfsStack.push(m);
          m.placeBreadcrumb();
        }
      }
    }  
    return false;
  }

  /** Returns the shortest path through the social network from node x to node y.
   *  If more than one path is the shortest, returns any of the shortest ones. 
   *  If there is no path from x to y, returns null. 
   *  Makes use of each node's parent: the first node 
   *  that added the node to the search.
   */
  public List<Agent> bacon(Agent a, Agent b) {
    SocialNetworkNode origin = getNode(a);
    SocialNetworkNode dest = getNode(b);
    if (origin == null || dest == null)
      return null;
    removeBreadcrumbs();
    Queue<SocialNetworkNode> bfsQueue = new Queue<SocialNetworkNode>();   
    bfsQueue.add(origin);
    origin.placeBreadcrumb();
    while (!bfsQueue.isEmpty()) {
      SocialNetworkNode n = bfsQueue.poll();
      if (n == dest)
        return rollBack(n);
      for (Agent c : adjDict.get(n.getAgent()).keySet()) {
        SocialNetworkNode m = c.getSNNode();
        if (!m.hasBreadcrumb()) {
          bfsQueue.add(m);
          m.placeBreadcrumb(n); // sets m's parent to n
        }
      }
    }  
    return null;
  }

  /** Returns a path that goes to each node from its parent,
   *  starting at the root ancestor and ending at the given node. 
   *
   *  If the given node is the root, returns the path root -> root.
   */
  private List<Agent> rollBack(SocialNetworkNode end) {
    ArrayList<Agent> path = new ArrayList<Agent>();
    path.add(0, end.getAgent());
    while (end.getParent() != null) {
      end = end.getParent();
      path.add(0, end.getAgent());
    }
    if (path.size() == 1)
      path.add(end.getAgent()); //special case for path to self.
    return path;
  }
}
