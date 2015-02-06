#include <fstream>

#include <SkelCL/SkelCL.h>
#include <SkelCL/Vector.h>
#include <SkelCL/Map.h>

#include "../common.h"
#include "./kernel_gpu_skelcl_wrapper.h"
#include "../util/timer/timer.h"

using namespace skelcl;

void kernel_gpu_skelcl_wrapper( record *records,
				long records_elem,
				knode *knodes,
				long knodes_elem,

				int order,
				long maxheight,
				int count,

				int *keys,
				record *ans)
{
  long long time0, time1, time2;

  time0 = get_time();

  //detail::DeviceProperties d=allDevices();
  detail::DeviceProperties d=nDevices(1);
  d.deviceType(device_type::GPU);
  skelcl::init(d);

  //skelcl::init(nDevices(1));

  Map<record(int)> m(std::ifstream("./kernel/kernel_gpu_skelcl.cl"));
  Vector<record> vecRecords(records, records + records_elem);
  Vector<knode> vecKnodes(knodes, knodes + knodes_elem);
  Vector<int> vecKeys(count);

  time1 = get_time();

  for(int i=0;i<count;i++)
    vecKeys[i]=keys[i];

  vecKeys.setDistribution(distribution::Block(vecKeys));
  vecRecords.setDistribution(distribution::Copy(vecRecords));
  vecKnodes.setDistribution(distribution::Copy(vecKnodes));

  //Begin 
  Vector<record> vecAns = m(vecKeys, maxheight, order, vecKnodes, knodes_elem, vecRecords);
  
  for(unsigned int i=0; i<vecAns.size(); i++)
    ans[i].value=vecAns[i].value;

  time2 = get_time();
  
  //Show times
  //  printf("%15.12f s, %15.12f %% : GPU: SET DEVICE / DRIVER INIT\n", (float) (time1-time0) / 1000000, (float) (time1-time0) / (float) (time2-time0) * 100);
  //  printf("%15.12f s, %15.12f %% : GPU: COMPUTATION\n", (float) (time2-time1) / 1000000, (float) (time2-time1) / (float) (time2-time0) * 100);
  //  printf("Total time:\n");
  printf("# searches = %d, order = %d \n", count, order);
  printf("%.12f\n", (float) (time2-time0) / 1000000);


}
