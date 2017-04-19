#include <stdlib.h>

#include <iostream>
#include "cuddObj.hh"
typedef Cudd bddMgr;

void 
test_BDD() {
  bddMgr mgr (0, 0);
  BDD a = mgr.bddVar();
  BDD b = mgr.bddVar();
  BDD c = mgr.bddVar();
  BDD d = mgr.bddVar();

  std::vector<BDD> nodes;

  BDD R = (a & b) | (c & d);

  nodes.push_back(R);
  
  const char *inames[] = {"a", "b", "c", "d"};
  const char *onames[] = {"R"};
  FILE *fptr = fopen("who.dot", "w");
  mgr.DumpDot(nodes, (char **) inames, (char **) onames, fptr);
  fclose(fptr);


}

/* See:
 *
 * http://students.cs.byu.edu/~cs486ta/handouts/f04/bdd-package.html 
 *
 * For detailed instructions.
 */

int 
main(int argc, char* argv[]) {
  test_BDD();
  return 0;
}
