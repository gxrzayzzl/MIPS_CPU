#include <fstream>
#include <iostream>
#include <string>
#include <map>
#include <queue>
#include <vector>

using namespace std;

enum InsType {B,R,L,I,S,Z,J,JR,W,JRL};

typedef map<string,string> MyMap;
typedef map<string,InsType> TypeMap;
typedef map<string,int> PosMap;
typedef queue<string> TmpStr;
typedef vector<string> StrVector;

void initMap(TypeMap& InstroctionType,MyMap& OptionCode,MyMap& Registers,MyMap& FunctionCode)
{
	//初始化设定所有指令的格式
	InstroctionType.insert(pair<string,InsType>("lw",InsType::W));
	InstroctionType.insert(pair<string,InsType>("sw",InsType::W));  //取字的格式特殊，单独提出
	InstroctionType.insert(pair<string,InsType>("lui",InsType::L)); //lui的格式特殊，单独提出
	InstroctionType.insert(pair<string,InsType>("add",InsType::R));
	InstroctionType.insert(pair<string,InsType>("addu",InsType::R));
	InstroctionType.insert(pair<string,InsType>("sub",InsType::R));
	InstroctionType.insert(pair<string,InsType>("subu",InsType::R));
	InstroctionType.insert(pair<string,InsType>("addi",InsType::I));
	InstroctionType.insert(pair<string,InsType>("addiu",InsType::I));
	InstroctionType.insert(pair<string,InsType>("and",InsType::R));
	InstroctionType.insert(pair<string,InsType>("or",InsType::R));
	InstroctionType.insert(pair<string,InsType>("xor",InsType::R));
	InstroctionType.insert(pair<string,InsType>("nor",InsType::R));
	InstroctionType.insert(pair<string,InsType>("andi",InsType::I));
	InstroctionType.insert(pair<string,InsType>("sll",InsType::S));
	InstroctionType.insert(pair<string,InsType>("srl",InsType::S)); //三个移位格式特殊，单独提出
	InstroctionType.insert(pair<string,InsType>("sra",InsType::S));
	InstroctionType.insert(pair<string,InsType>("slt",InsType::R));
	InstroctionType.insert(pair<string,InsType>("slti",InsType::I));
	InstroctionType.insert(pair<string,InsType>("sltiu",InsType::I));
	InstroctionType.insert(pair<string,InsType>("beq",InsType::B));
	InstroctionType.insert(pair<string,InsType>("bne",InsType::B));
	InstroctionType.insert(pair<string,InsType>("blez",InsType::Z));
	InstroctionType.insert(pair<string,InsType>("bgtz",InsType::Z));
	InstroctionType.insert(pair<string,InsType>("bltz",InsType::Z));
	InstroctionType.insert(pair<string,InsType>("j",InsType::J));
	InstroctionType.insert(pair<string,InsType>("jal",InsType::J));
	InstroctionType.insert(pair<string,InsType>("jr",InsType::JR)); //两个jr形式特殊，单独提出
	InstroctionType.insert(pair<string,InsType>("jalr",InsType::JRL));

	//初始化所有指令的操作码
	OptionCode.insert(pair<string,string>("lw","6'h23"));
	OptionCode.insert(pair<string,string>("sw","6'h2b"));
	OptionCode.insert(pair<string,string>("lui","6'h0f"));
	OptionCode.insert(pair<string,string>("add","6'h0"));
	OptionCode.insert(pair<string,string>("addu","6'h0"));
	OptionCode.insert(pair<string,string>("sub","6'h0"));
	OptionCode.insert(pair<string,string>("subu","6'h0"));
	OptionCode.insert(pair<string,string>("addi","6'h08"));
	OptionCode.insert(pair<string,string>("addiu","6'h09"));
	OptionCode.insert(pair<string,string>("and","6'h0"));
	OptionCode.insert(pair<string,string>("or","6'h0"));
	OptionCode.insert(pair<string,string>("xor","6'h0"));
	OptionCode.insert(pair<string,string>("nor","6'h0"));
	OptionCode.insert(pair<string,string>("andi","6'h0"));
	OptionCode.insert(pair<string,string>("sll","6'h0"));
	OptionCode.insert(pair<string,string>("srl","6'h0"));
	OptionCode.insert(pair<string,string>("sra","6'h0"));
	OptionCode.insert(pair<string,string>("slt","6'h0"));
	OptionCode.insert(pair<string,string>("slti","6'h0a"));
	OptionCode.insert(pair<string,string>("sltiu","6'h23"));
	OptionCode.insert(pair<string,string>("beq","6'h04"));
	OptionCode.insert(pair<string,string>("bne","6'h05"));
	OptionCode.insert(pair<string,string>("blez","6'h06"));
	OptionCode.insert(pair<string,string>("bgtz","6'h07"));
	OptionCode.insert(pair<string,string>("bltz","6'h01"));
	OptionCode.insert(pair<string,string>("j","6'h02"));
	OptionCode.insert(pair<string,string>("jal","6'h03"));
	OptionCode.insert(pair<string,string>("jr","6'h0"));
	OptionCode.insert(pair<string,string>("jalr","6'h0"));

	//定好所有寄存器的位置
	Registers.insert(pair<string,string>("$zero","5'd0"));
	Registers.insert(pair<string,string>("$at","5'd1"));
	Registers.insert(pair<string,string>("$v0","5'd2"));
	Registers.insert(pair<string,string>("$v1","5'd3"));
	Registers.insert(pair<string,string>("$a0","5'd4"));
	Registers.insert(pair<string,string>("$a1","5'd5"));
	Registers.insert(pair<string,string>("$a2","5'd6"));
	Registers.insert(pair<string,string>("$a3","5'd7"));
	Registers.insert(pair<string,string>("$t0","5'd8"));
	Registers.insert(pair<string,string>("$t1","5'd9"));
	Registers.insert(pair<string,string>("$t2","5'd10"));
	Registers.insert(pair<string,string>("$t3","5'd11"));
	Registers.insert(pair<string,string>("$t4","5'd12"));
	Registers.insert(pair<string,string>("$t5","5'd13"));
	Registers.insert(pair<string,string>("$t6","5'd14"));
	Registers.insert(pair<string,string>("$t7","5'd15"));
	Registers.insert(pair<string,string>("$s0","5'd16"));
	Registers.insert(pair<string,string>("$s1","5'd17"));
	Registers.insert(pair<string,string>("$s2","5'd18"));
	Registers.insert(pair<string,string>("$s3","5'd19"));
	Registers.insert(pair<string,string>("$s4","5'd20"));
	Registers.insert(pair<string,string>("$s5","5'd21"));
	Registers.insert(pair<string,string>("$s6","5'd22"));
	Registers.insert(pair<string,string>("$s7","5'd23"));
	Registers.insert(pair<string,string>("$t8","5'd24"));
	Registers.insert(pair<string,string>("$t9","5'd25"));
	Registers.insert(pair<string,string>("$k0","5'd26"));
	Registers.insert(pair<string,string>("$k1","5'd27"));
	Registers.insert(pair<string,string>("$gp","5'd28"));
	Registers.insert(pair<string,string>("$sp","5'd29"));
	Registers.insert(pair<string,string>("$fp","5'd30"));
	Registers.insert(pair<string,string>("$ra","5'd31"));

	//初始化R型指令的ALU操作码
	FunctionCode.insert(pair<string,string>("add","6'h20"));
	FunctionCode.insert(pair<string,string>("addu","6'h21"));
	FunctionCode.insert(pair<string,string>("sub","6'h22"));
	FunctionCode.insert(pair<string,string>("subu","6'h23"));
	FunctionCode.insert(pair<string,string>("and","6'h24"));
	FunctionCode.insert(pair<string,string>("or","6'h25"));
	FunctionCode.insert(pair<string,string>("xor","6'h26"));
	FunctionCode.insert(pair<string,string>("nor","6'h27"));
	FunctionCode.insert(pair<string,string>("sll","6'h0"));
	FunctionCode.insert(pair<string,string>("srl","6'h02"));
	FunctionCode.insert(pair<string,string>("sra","6'h03"));
	FunctionCode.insert(pair<string,string>("slt","6'h2a"));
	FunctionCode.insert(pair<string,string>("jr","6'h08"));
	FunctionCode.insert(pair<string,string>("jalr","6'h09"));
}

string itoa(int num)
{
	int value = -1;
	string temp = "";
	do
	{
		value = num%10;
		temp.insert(0,1,(char)(value+48));
		num = num/10;
	}while(num!=0);
	return temp;
}

StrVector SplitStr(string str)
{
	StrVector ans;
	int tmp;
	while(str!="")
	{
		tmp = str.find_first_of(" ;(),\n\t");
		ans.push_back(str.substr(0,tmp));
		if(tmp == -1) { break; }
		str.erase(0,tmp+1);
	}
	return ans;
}

int main()
{
	fstream file,target;
	MyMap functionCode,optionCode,registers;
	TypeMap instroctionType;
	PosMap Labels;
	StrVector LabelStr;
	int labelCount = 0;
	TmpStr tmpStr;
	initMap(instroctionType,optionCode,registers,functionCode);
	file.open("code.txt",ios::in);
	target.open("result.txt",ios::out);
	string ins;
	string firstWord;
	int line = 0;
	while(getline(file,ins))
	{
		if(ins == "") { continue; }
		int location = ins.find_first_of(" ;:,\n");
		firstWord = ins.substr(0,location);
		if(instroctionType.count(firstWord)==0)
		{
			ins.erase(0,location+1);
			Labels.insert(pair<string,int>(firstWord,line));
			LabelStr.push_back(firstWord);
			labelCount ++;
			while(ins[0] == ' ')
			{
				ins.erase(0,1);
			}
			location = ins.find_first_of(" ;:,\n");
			firstWord = ins.substr(0,location);
			if(ins == "") { continue; }
		}
		StrVector tmpStrList = SplitStr(ins);
		string str = "ROMDATA[" + itoa(line) + "] <= {" + 
			optionCode.find(tmpStrList[0])->second + ',';
		switch(instroctionType.find(firstWord)->second)
		{
		case InsType::R: 
			str = str +
				registers.find(tmpStrList[2])->second + ',' +
				registers.find(tmpStrList[3])->second + ',' +
				registers.find(tmpStrList[1])->second + ',' +
				"5'b0," + 
				functionCode.find(tmpStrList[0])->second;
			break;
		case InsType::I: 
			str = str +
				registers.find(tmpStrList[2])->second + ',' +
				registers.find(tmpStrList[1])->second + ',' +
				"16'd" + tmpStrList[3];
			break;
		case InsType::J: 
			str = str + tmpStrList[1] + 'J';
			break;
		case InsType::JR:
			str = str +
				registers.find(tmpStrList[1])->second + ',' +
				"15'b0," + 
				functionCode.find(tmpStrList[0])->second;
			break;
		case InsType::JRL: 
			str = str +
				registers.find(tmpStrList[2])->second + ',' +
				"5'b0," + 
				registers.find(tmpStrList[1])->second + ',' +
				"5'b0," + 
				functionCode.find(tmpStrList[0])->second;
			break;
		case InsType::L: 
			str = str +
				"5'b0," +
				registers.find(tmpStrList[1])->second + ',' +
				"16'd" + tmpStrList[2];
			break;
		case InsType::S: 
			str = str +
				"5'b0," +
				registers.find(tmpStrList[2])->second + ',' +
				registers.find(tmpStrList[1])->second + ',' +
				"5'd" + tmpStrList[3] +
				functionCode.find(tmpStrList[0])->second;
			break;
		case InsType::B:
			str = str +
				registers.find(tmpStrList[2])->second + ',' +
				registers.find(tmpStrList[1])->second + ',' +
				tmpStrList[3] + 'B';
			break;
		case InsType::Z:
			str = str +
				registers.find(tmpStrList[1])->second + ',' +
				"5'b0," + tmpStrList[2] + 'B';
			break;
		case InsType::W:
			str = str +
				registers.find(tmpStrList[3])->second + ',' +
				registers.find(tmpStrList[1])->second + ',' +
				"16'd" + tmpStrList[2];
			break;
		}
		cout<<"line " + itoa(line) + " has decoded\n";
		cout<<ins<<endl;
		str = str + "};\n";
		line ++;
		tmpStr.push(str);
	}
	line = 0;
	string change;
	while(!tmpStr.empty())
	{
		for(int i = 0;i<labelCount;i++)
		{
			if(tmpStr.front().find(LabelStr[i]) != string::npos)
			{
				if(tmpStr.front().find(LabelStr[i]+'B') != string::npos)
				{
					if(Labels.find(LabelStr[i])->second - line + 1 > 0)
					{
						change = "16'd" + itoa(Labels.find(LabelStr[i])->second - line + 1);
					}
					else
					{
						change = "-16'd" + itoa(line - 1 - Labels.find(LabelStr[i])->second);
					}
					tmpStr.front().replace(tmpStr.front().find(LabelStr[i]+'B'),(LabelStr[i]+'B').length(),change);
				}
				else
				{
					change = "26'd" + itoa(4 * Labels.find(LabelStr[i])->second);
					tmpStr.front().replace(tmpStr.front().find(LabelStr[i]+'J'),(LabelStr[i]+'J').length(),change);
				}
				break;
			}
		}
		target.write(tmpStr.front().c_str(),sizeof(char)*tmpStr.front().length());
		tmpStr.pop();
		line++;
	}

	return 0;
}