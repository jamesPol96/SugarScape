import java.util.LinkedList;
import java.util.Collections;

interface MovementRule {
  public Square move(LinkedList<Square> neighborhood, SugarGrid g, Square middle);
}

class SugarSeekingMovementRule implements MovementRule {
  /* The default constructor. For now, does nothing.
  *
  */
  public SugarSeekingMovementRule() {
  }
  
  /* For now, returns the Square containing the most sugar. 
  *  In case of a tie, use the Square that is closest to the middle according 
  *  to g.euclidianDistance(). 
  *  Squares should be considered in a random order (use Collections.shuffle()). 
  */
  public Square move(LinkedList<Square> neighborhood, SugarGrid g, Square middle) {
    Square retval = neighborhood.peek();
    Collections.shuffle(neighborhood);
    for (Square s : neighborhood) {
      if (s.getSugar() > retval.getSugar() ||
          (s.getSugar() == retval.getSugar() && 
           g.euclideanDistance(s, middle) < g.euclideanDistance(retval, middle)
          )
         ) {
        retval = s;
      } 
    }
    return retval;
  }
}

class PollutionMovementRule implements MovementRule {
  /* The default constructor. For now, does nothing.
  *
  */
  public PollutionMovementRule() {
  }
  
  /* For now, returns the Square containing the most sugar. 
  *  In case of a tie, use the Square that is closest to the middle according 
  *  to g.euclidianDistance(). 
  *  Squares should be considered in a random order (use Collections.shuffle()). 
  */
  public Square move(LinkedList<Square> neighborhood, SugarGrid g, Square middle) {
    Square retval = neighborhood.peek();
    Collections.shuffle(neighborhood);
    boolean bestSquareHasNoPollution = (retval.getPollution() == 0);
    for (Square s : neighborhood) {
      boolean newSquareCloser = (g.euclideanDistance(s, middle) < g.euclideanDistance(retval, middle));
      if (s.getPollution() == 0) {
        if (!bestSquareHasNoPollution || s.getSugar() > retval.getSugar() ||
            (s.getSugar() == retval.getSugar() && newSquareCloser)
           ) {
          retval = s;
        }
      }
      else if (!bestSquareHasNoPollution) { 
        float newRatio = s.getSugar()*1.0/s.getPollution();
        float curRatio = retval.getSugar()*1.0/retval.getPollution();
        if (newRatio > curRatio || (newRatio == curRatio && newSquareCloser)) {
          retval = s;
        }
      }
    }
    return retval;
  }
}

class CombatMovementRule extends SugarSeekingMovementRule {
  
  int alpha;
  Square target;
  Agent casualty;
  
  public CombatMovementRule(int alpha) {
    this.alpha = alpha;
  }
  
  public Square move(LinkedList<Square> neighbourhood, SugarGrid g, Square middle) {
    LinkedList<Square> possibleSquares = neighbourhood;
    
    for (Square s: neighbourhood) {
      if (s.getAgent() != null) {
        if (s.getAgent().getTribe() == middle.getAgent().getTribe()) {
          possibleSquares.remove(s);
        }
        else if (s.getAgent().getSugarLevel() >= middle.getAgent().getSugarLevel()) {
          possibleSquares.remove(s);
        }
      }
    }
    
    for (Square s: neighbourhood) {
      if (!possibleSquares.contains(s)) {
        continue;
      }
      LinkedList <Square> vision = g.generateVision(s.getX(), s.getY(), middle.getAgent().getVision());
      for (Square s2: vision) {
        if(s2.getAgent().getTribe() != middle.getAgent().getTribe() && s2.getAgent().getSugarLevel() > middle.getAgent().getSugarLevel()) {
          possibleSquares.remove(s);
          break;
        }
      }
    }
    
    for(Square s: neighbourhood) {
      if (!possibleSquares.contains(s)) {
        continue;
      }
      if (s.getAgent() != null) {
        int increase = min(alpha, s.getAgent().getSugarLevel());
        Square newS = new Square(s.getSugar() + increase, s.getMaxSugar() + increase, s.getX(), s.getY());
        possibleSquares.set(possibleSquares.indexOf(s), newS);
      }
    }
    
    Square moveTarget = super.move(possibleSquares, g, middle);
    
    for(Square s: neighbourhood) {
      if (s.getX() == moveTarget.getX() && s.getY() == moveTarget.getY()) {
        this.target = s;
      }
    }
    if (this.target.getAgent() == null) {
      return this.target;
    }
    else {
      this.casualty = this.target.getAgent();
      this.target.setAgent(null);
      middle.getAgent().sugarLevel += min(alpha, this.casualty.getSugarLevel());
      g.killAgent(casualty);
      return this.target;
    }
  }
}

class SugarSeekingMovementRuleTester {
  public void test() {
    SugarSeekingMovementRule mr = new SugarSeekingMovementRule();
    //stubbed
  }
}

class PollutionMovementRuleTester {
  public void test() {
    PollutionMovementRule mr = new PollutionMovementRule();
    //stubbed
  }
}
