import java.util.ArrayList;
import java.util.Set;
import java.util.HashSet;
import java.util.Collections;

/* A Dictionary implementation that stores an ArrayList of Key-Value Pairs sorted by Key
 */
public class ArrayDictionary<K extends Comparable<K>, V> implements Dictionary<K, V>
{
  private ArrayList<Pair<K,V>> storage;
  private Set<K> keySet;
  
  public void bulkAdd(ArrayList<Pair<K,V>> data){
    storage.addAll(data);
    Collections.sort(storage); 
    for (Pair<K,V> pair: storage) {
      keySet.add(pair.getKey());
    }
  }
  public ArrayDictionary(){
    storage = new ArrayList<Pair<K,V>>(); 
    keySet = new HashSet<K>();
  }
  
  public void clear(){
    storage = new ArrayList<Pair<K,V>>();    
  }
  
  public int size(){
    return this.storage.size();    
  }

  /* This doesn't need binary search because the ArrayList may need to shift O(n) elements in the call to add()
   */
  public void put(K pkey, V value){
    Pair<K,V> target = new Pair<K,V>(pkey, value);
    // if target is less than or equal to an existing pair, add or replace it
    for(int i=0; i < storage.size(); i++)
      if(target.compareTo(storage.get(i)) <= 0) {
        if(target.compareTo(storage.get(i)) == 0)
          storage.set(i, target);
        else
          storage.add(i,target);
          keySet.add(pkey);
        return;
      }
    // target is larger than any existing pair: add to the end
    storage.add(target); 
    keySet.add(pkey);
  }
  
  /* This doesn't need binary search because the ArrayList may need to shift O(n) elements in the call to remove()
   */
  public V remove(K pkey){
    Pair<K,V> target = new Pair<K,V>(pkey, null);
    for(int i=0; i < storage.size(); i++)
      if(target.compareTo(storage.get(i)) <= 0)
        if(target.compareTo(storage.get(i)) == 0) {
          keySet.remove(pkey);
          return storage.remove(i).getValue();
        }
        else
          return null; // less than i-th item - therefore not in the list.
    return null; 
  }
  
  /* Returns the index in the ArrayList of the Pair
   *
   */
  private int binSearch(Pair<K,V> pair){
    int start = 0;
    int end = this.storage.size();
    int mid;
    
    while(start < end){
        mid = (end - start)/2 + start;
        int res = storage.get(mid).compareTo(pair);
        if(res == 0)
            return mid;
        else if(res < 0)
          start = mid+1;
        else
          end = mid;
    }
    return -1;
  }
  
  public boolean containsKey(K pkey){
    return binSearch(new Pair<K,V>(pkey,null)) != -1;    
  }
  
  public V get(K pkey){
    int location = binSearch(new Pair<K,V>(pkey,null));
    if(location == -1)
      return null;
    else
      return storage.get(location).getValue();
  }
  
  /* Modeled on HashMap's keySet() but uses a Set instance instead of a view.
   */
  public Set<K> keySet() {
    return keySet;
  }
}
