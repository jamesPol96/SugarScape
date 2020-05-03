import java.util.Map;

class FertilityRule {
  Map<Character, Integer[]> childbearingOnset;
  Map<Character, Integer[]> climactericOnset;
  ArrayDictionary ageDict;
  ArrayDictionary sugarDict;
  
  public FertilityRule(Map<Character, Integer[]> childbearingOnset, Map<Character, Integer[]> climactericOnset) {
    this.childbearingOnset = childbearingOnset;
    this.climactericOnset = climactericOnset;
    this.ageDict = new ArrayDictionary();
    this.sugarDict = new ArrayDictionary();
  }
  
  public boolean isFertile(Agent a) {
    if (a == null) {
      return false;
    }
    else if (!a.isAlive()) {
      ageDict.remove(a);
      sugarDict.remove(a);
      return false;
    }
    else {
      if (ageDict.containsKey(a) == false) {
        int childbearingAge = (int)random(this.childbearingOnset.get(a.getSex())[0], this.childbearingOnset.get(a.getSex())[1]+1);
        int climactericAge = (int)random(this.climactericOnset.get(a.getSex())[0], this.climactericOnset.get(a.getSex())[1]+1);
        int[] fertility = new int[] {childbearingAge, climactericAge};
        this.ageDict.put(a, fertility);
        this.sugarDict.put(a, a.getSugarLevel());
      }
      if (((int[])this.ageDict.get(a))[0] <= a.getAge() && ((int[])this.ageDict.get(a))[1] > a.getAge() && (int)this.sugarDict.get(a) <= a.getSugarLevel()){
        return true;
      }
      else return false;
    }
  }
  
  public boolean canBreed(Agent a, Agent b, LinkedList<Square> local) {
    if (!isFertile(a)) {
      return false;
    }
    if (!isFertile(b)) {
      return false;
    }
    if (a.getSex() == b.getSex()) {
      return false;
    }
    boolean bNearA = false;
    boolean existsEmptySquare = false;
    for(int i = 0; i < local.size(); i++) {
      if (local.get(i).getAgent() == null) {
        existsEmptySquare = true;
      }
      else if (local.get(i).getAgent().equals(b)) {
        bNearA = true;
      }
    }
    if(bNearA && existsEmptySquare) return true;
    else return false;
  }
  
  public Agent breed(Agent a, Agent b, LinkedList<Square> aLocal, LinkedList<Square> bLocal) {
    if (!canBreed(a, b, aLocal) && !canBreed(b, a, bLocal)) {
      return null;
    }
    int metabolism;
    if(Math.random() < .5){
      metabolism = a.getMetabolism();
    }
    else metabolism  = b.getMetabolism();
    
    int vision;
    if(Math.random() < .5){
      vision = a.getVision();
    }
    else vision = b.getVision();
    
    MovementRule m = a.getMovementRule();
    
    char sex;
    if(Math.random() < .5){
      sex = 'X';
    }
    else sex = 'Y';
    
    Agent newChild = new Agent(metabolism, vision, 0, m, sex);
    
    newChild.gift(a, (int)sugarDict.get(a)/2);
    newChild.gift(b, (int)sugarDict.get(b)/2);
    
    LinkedList<Square> emptySquares = new LinkedList<Square>();
    
    for(Square s: aLocal) {
      if (s.getAgent() == null) {
        emptySquares.add(s);
      }
    }
    for(Square s: bLocal) {
      if (s.getAgent() == null) {
        emptySquares.add(s);
      }
    }
    
    newChild.nurture(a, b);
    
    Collections.shuffle(emptySquares);
    emptySquares.get(0).setAgent(newChild);
    
    return newChild;
  }
}
