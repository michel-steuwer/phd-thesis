#include <fstream>

#include <pvsutil/Logger.h>
#include <pvsutil/CLArgParser.h>

#include <SkelCL/SkelCL.h>
#include <SkelCL/Matrix.h>
#include <SkelCL/IndexVector.h>
#include <SkelCL/Map.h>
#include <SkelCL/Scan.h>

#include "nw.cpp"

//Print out a matrix for debbug-logging.
std::string print(skelcl::Matrix<int> *matrix, std::string name, bool dl){ 
	std::string tmp = name;
	if(dl){
		tmp.append(":\n");
		for(int i = 0; i < (*matrix).size().rowCount(); i++)
		{
			tmp.append(std::to_string((*matrix)[i][0]));
			for(int j = 1; j < (*matrix).size().columnCount(); j++)
			{
				tmp.append(", ");
				tmp.append(std::to_string((*matrix)[i][j]));
			}
			tmp.append("\n");
		}	
	}
	return tmp;
}

//This traceback is related to the traceback from the original OpenCL programm in nw.cl. The instructions in the comments boardered in "---" are changed to the given situation. 
std::string traceback(skelcl::Matrix<int>* result, std::vector<int> seqx, std::vector<int> seqy, int penalty){
	int j = (*result).size().rowCount() -1;
	int i = j;
	std::string tb = "";
	
	for (; i>=0, j>=0;){
		int nw, n, w, traceback;
		if ( i == (*result).size().rowCount() -1 && j == (*result).size().rowCount() -1 )
			tb.append(std::to_string((*result)[j][i])); //---fprintf(fpo, "%d ", output_itemsets[ i * max_cols + j]); //print the first element---
		if ( i == 0 && j == 0 )
           break;
		if ( i > 0 && j > 0 ){
			nw = (*result)[j-1][i -1]; //---output_itemsets[(i - 1) * max_cols + j - 1];---
		    w  = (*result)[j-1][i]; //---output_itemsets[ i * max_cols + j - 1 ];---
            n  = (*result)[j][i -1]; //---output_itemsets[(i - 1) * max_cols + j];---
		}
		else if ( i == 0 ){
		    nw = n = LIMIT;
		    w  = (*result)[j-1][i]; //---output_itemsets[ i * max_cols + j - 1 ];---
		}
		else if ( j == 0 ){
		    nw = w = LIMIT;
            n  = (*result)[j][i -1]; //---output_itemsets[(i - 1) * max_cols + j];---
		}
		else{
		}

		int new_nw, new_w, new_n;
		new_nw = nw + blosum62[seqx[j]][seqy[i]];; //---reference[i * max_cols + j];---
		new_w = w - penalty;
		new_n = n - penalty;
		
		traceback = maximum(new_nw, new_w, new_n);
		if(traceback == new_nw)
			traceback = nw;
		if(traceback == new_w)
			traceback = w;
		if(traceback == new_n)
            traceback = n;
			
		tb.append(", ");	
		tb.append(std::to_string(traceback)); //---fprintf(fpo, "%d ", traceback);---

		if(traceback == nw )
		{i--; j--; continue;}

        else if(traceback == w )
		{j--; continue;}

        else if(traceback == n )
		{i--; continue;}

		else
		;
	}
	
	return tb;
}

void needleman_wunsch_with_skelcl(int dimension, int penalty, int wgs, bool dl){
	auto t1 = std::chrono::high_resolution_clock::now(); //timestamp
	skelcl::Matrix<int> reference = skelcl::Matrix<int>({dimension, dimension}); //matrix for the calculation
	std::vector<int> seqx = std::vector<int>(dimension); //vector for a sequence
	std::vector<int> seqy = std::vector<int>(dimension); //vector for a sequence
	reference[0][0] = 0; //set initial value for calculation
	
	srand(7); //set seed for random generator
	
	//generate random sequence
	std::string seqystr = ""; 
	for(int j = 1; j <= dimension; j++){
		seqy[j] = rand() % 10 + 1;
		if(dl){seqystr.append(std::to_string(seqy[j])) += ", ";}
	}
	
	//generate random sequence
	std::string seqxstr = "";
	for(int i = 1; i <= dimension; i++){
		seqx[i] = rand() % 10 + 1;
		if(dl){seqxstr.append(std::to_string(seqx[i])) += ", ";}
	}
	LOG_DEBUG("Sequence X: ", seqxstr);
	LOG_DEBUG("Sequence Y: ", seqystr);
	
	//set the values from the Substitution matrix
	for (int i = 1 ; i < dimension; i++){
		for (int j = 1 ; j < dimension; j++){
		reference[i][j] = blosum62[seqx[i]][seqy[j]];
		}
	}
	//set border values
	for(int i = 1; i < dimension; i++){
	  reference[i][0] = i * (-penalty);
	  reference[0][i] = i * (-penalty);
	}
	
	auto t2 = std::chrono::high_resolution_clock::now(); //timestamp
	LOG_INFO("Prepare Matrix: ", std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1).count(), "ms");  //logging the runtime
		
	skelcl::Map<void(skelcl::Index)> upper_left(std::ifstream("upper_left.cl"));
	upper_left.setWorkGroupSize(wgs);
	skelcl::Map<void(skelcl::Index)> lower_right(std::ifstream("lower_right.cl"));
	lower_right.setWorkGroupSize(wgs);
	
	auto t3 = std::chrono::high_resolution_clock::now(); //timestamp
	LOG_INFO("Load kernels / prepair skeleton: ", std::chrono::duration_cast<std::chrono::milliseconds>(t3 - t2).count(), "ms");  //logging the runtime
	
	//perform calculation for upper left matrix
	for(int i = 1; i <= dimension /wgs; i++){
		skelcl::IndexVector index = skelcl::IndexVector(i *wgs);
		
		local size: ", sizeof(int) * (wgs +1) * (wgs +1));
		upper_left(index, skelcl::out(reference), skelcl::Local(sizeof(int) * (wgs +1) * (wgs +1)), i, penalty, dimension, wgs);
	}
	//perform calculation for lower right matrix
	for(int i = (dimension /wgs) -1; i > 0 ; i--){
		skelcl::IndexVector index = skelcl::IndexVector(i *wgs);
		
 local size: ", sizeof(int) * (wgs +1) * (wgs +1));
		lower_right(index, skelcl::out(reference), skelcl::Local(sizeof(int) * (wgs +1) * (wgs +1)), i, penalty, dimension, wgs);
	}

	auto t4 = std::chrono::high_resolution_clock::now(); //timestamp
	LOG_INFO("Perform kernels: ", std::chrono::duration_cast<std::chrono::milliseconds>(t4 - t3).count(), "ms");  //logging the runtime
	LOG_INFO("Traceback:    ", traceback(&reference, seqx, seqy, penalty)); //perform traceback
	auto t5 = std::chrono::high_resolution_clock::now(); //timestamp
	LOG_INFO("Time for Traceback: ", std::chrono::duration_cast<std::chrono::milliseconds>(t5 - t4).count(), "ms");  //logging the runtime
}

int main(int argc, char **argv){
	using namespace pvsutil::cmdline;
  pvsutil::CLArgParser cmd(Description("Needleman–Wunsch algorithm calculate an optimal global alignment on two sequences."));
  
  auto dimension = 				Arg<int>				(	Flags(Short('n'), Long("dimension")),
		                            						Description("x and y dimensions of the sample matrix - Must be a multiple of 16 for original programm."),
		                            						Default(256)
		                            					); 
		                            					
	auto penalty = 					Arg<int>				(	Flags(Short('p'), Long("penalty")),
		                            						Description("Penalty (positive integer) for inserted gaps."),
		                            						Default(10)
		                            					); 
		                            
	auto wgs = 							Arg<int>				(	Flags(Short('w'), Long("work_group_size")),
		                            						Description("Work-Group size - Must be a divisor of the dimension and depends on the hardware of the OpenCl-Device."),
		                            						Default(16)
		                            					); 
		                            		
	auto filename = 				Arg<std::string>(	Flags(Short('f'), Long("filename")),
		                            						Description("OpenCL kernel for the original programm."),
		                            						Default(std::string("./nw.cl"))
		                            					); 
		                            					
	auto enableLogging =		Arg<bool>				(	Flags(Short('v'), Long("logging"), Long("verbose_logging")),
								                         		Description("Enable verbose logging."),
								                         		Default(false)
								                         	);
																
	auto enableDebugLogging =	Arg<bool>			(	Flags(Short('d'), Long("debug_logging")),
						                           				Description("Enable debug logging."),
						                           				Default(false)
						                           			);
						                           			
	auto runOriginal 				=	Arg<bool>			(	Flags(Short('o'), Long("original")),
						                           				Description("Run original OpenCL-programm. (The Work-Group size is fixt at 16)"),
						                           				Default(false)
						                           			);

	cmd.add(&dimension, &penalty, &wgs, &runOriginal, &filename, &enableLogging, &enableDebugLogging); 
  cmd.parse(argc, argv);
  
  //set log level
  if(enableDebugLogging){
  	pvsutil::defaultLogger.setLoggingLevel(pvsutil::Logger::Severity::DebugInfo);
  }else if(enableLogging){
  	pvsutil::defaultLogger.setLoggingLevel(pvsutil::Logger::Severity::Info);
  }else{
  	pvsutil::defaultLogger.setLoggingLevel(pvsutil::Logger::Severity::Warning);
  }
	  
  if(runOriginal){
  	LOG_INFO("Run original version.");
  	//generate parameters for original programm
  	char* args[4]; 
  	args[0] = argv[0];
  	  	
  	char* filename_char_array = new char[filename.getValue().length()+1];
  	std::strcpy (filename_char_array, filename.getValue().c_str());
  	
  	std::string dimension_str = std::to_string(dimension.getValue());	
  	args[1] = new char[dimension_str.length()+1];
  	std::strcpy (args[1], dimension_str.c_str());
  	
  	std::string penalty_str = std::to_string(penalty.getValue());
  	args[2] = new char[penalty_str.length()+1];
  	std::strcpy (args[2], penalty_str.c_str());

  	args[3] = filename_char_array;
  	auto t1 = std::chrono::high_resolution_clock::now(); //timestamp
  	needleman_wunsch(4, args); //run origibal programm
  	auto t2 = std::chrono::high_resolution_clock::now(); //timestamp
  	LOG_INFO("Total runtime: ", std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1).count(), "ms"); //logging the runtime
  }else{
  	LOG_INFO("Run SkelCL version.");
  	if(dimension % wgs != 0){
  		LOG_ERROR("The Work-Group size must be a divisor of the dimension. Dimension: ", dimension, " - Work-Group size: ", wgs);
  		return EXIT_FAILURE;
  	}
  	auto t0 = std::chrono::high_resolution_clock::now(); //timestamp
  	skelcl::init(skelcl::nDevices(1)); //initialize SkelCL	
  	auto t1 = std::chrono::high_resolution_clock::now(); //timestamp
  	LOG_INFO("Initialize SkelCL: ", std::chrono::duration_cast<std::chrono::milliseconds>(t1 - t0).count(), "ms"); //logging the runtime
  	needleman_wunsch_with_skelcl(dimension, penalty, wgs, enableDebugLogging);
  	auto t2 = std::chrono::high_resolution_clock::now(); //timestamp
  	LOG_INFO("Total runtime without initialize Skelcl: ", std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1).count(), "ms"); //logging the runtime
  	LOG_INFO("Total runtime: ", std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t0).count(), "ms"); //logging the runtime
  }
  
  
  return EXIT_SUCCESS;
}

