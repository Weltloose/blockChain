pragma solidity ^0.4.24;

contract Link {
	// 定义核心企业向下游企业签发的应收账款 单据
	struct reciept {
		uint to;      // 欠谁
		bool used;       // 判断这个元素是否被占用
		uint amount;	 // 这张单据代表欠多少
		uint endTime;    // 还款到期时间
		bool payed;      // 标记该账单是否已经被偿还
	}
	
	enum FinanceCondition {
	    BANK_CHECKED, 
	    BANK_UNCHECKED
	}
	// 定义下游企业
	struct downStreamCompany {
		string name;    // 企业名称，用来还钱
		address self;   // 企业地址，用来确认是否自己操作
		uint[] owned;  // 持有的核心企业的债权，存储totReciepts的下标
		uint financed;  // 已经融资多少，防止下游企业重复使用债权去融资 
		FinanceCondition fc; // 该枚举类型是为了在增加用户融资时不仅要银行确认也要受者确认
	}
	address bank;			// 只定义一个银行
	address coreCompany;   // 只定义一个核心企业地址
	mapping(uint => downStreamCompany) downStreamCompanies;
	reciept[] totReciepts;
	bool[100] public unpaied;
	uint public curId;
	uint public inDebt;
	constructor(
		address _coreCompany,
		address _bank
	) public {
		inDebt = 0;
		coreCompany = _coreCompany;
		bank = _bank;
	}
	// 核心企业发放账单
	function addReciept(uint to, uint amount, uint endTime) internal returns(uint) {
		uint i;
		for(i = 0; i < totReciepts.length && totReciepts[i].used; i++){
		    
		}
		if(i == totReciepts.length){
			totReciepts.push(reciept(to, true, amount, endTime, false));
		}
		else{
			totReciepts[i].to = to;
			totReciepts[i].used = true;
			totReciepts[i].amount = amount;
			totReciepts[i].endTime = endTime;
			totReciepts[i].payed = false;
		}
		inDebt += amount;
		return i;
	}
	// 下游企业根据还款时间将账单推入自己存储totReciepts的下标数组中
	function pushIdxWFTDebtTime(uint to, uint idx) internal {
		downStreamCompanies[to].owned.push(0);
		uint i;
		// 按从早到晚排
		for(i = 0; i < downStreamCompanies[to].owned.length - 1; i++){
			if(totReciepts[idx].endTime < totReciepts[downStreamCompanies[to].owned[i]].endTime)
				break;
		}
		for(uint j = downStreamCompanies[to].owned.length - 1; j > i; j--){
			downStreamCompanies[to].owned[j] = downStreamCompanies[to].owned[j - 1];
		}
		downStreamCompanies[to].owned[i] = idx;
	}

	// 下游企业根据还款时间将账单抛出自己存储totReciepts的下标数组中
	function popIdxWFTDebtTime(uint to, uint idx) internal {
		for(uint i = idx; i < downStreamCompanies[to].owned.length - 1; i++){
			downStreamCompanies[to].owned[i] = downStreamCompanies[to].owned[i + 1];
		}
		downStreamCompanies[to].owned.length -= 1;
	}
	// 加入一个下游企业
	function AddDownStreamCompany(string name) public returns(uint) {
		++curId;
		downStreamCompanies[curId].self = msg.sender;
		downStreamCompanies[curId].name = name;
		return curId;
	}
	// 通过id获取下游企业名称
	function GetCompanyName(uint id) public returns(string) {
		return downStreamCompanies[id].name;
	}
	// 定义核心企业向下游企业签发应收账款函数
	function SignAndIssue(uint to, uint amount, uint debtTime) public {
		require(
			msg.sender == coreCompany,     // 该函数只能由核心企业发起
			"only coreCompany can sign and issue"
		);
		uint endTime = debtTime * 1000 + now;
		uint i = addReciept(to, amount, endTime);

		pushIdxWFTDebtTime(to, i);
	}
	// 获取某个下游企业所拥有的在多长时间以内就能获得付款的债权 
	function GetRight(uint owner, uint debtTime) public returns (uint){
		uint tot;
		uint endTime = now + debtTime * 1000;
		for(uint i = 0; i < downStreamCompanies[owner].owned.length && totReciepts[downStreamCompanies[owner].owned[i]].endTime <= endTime; i++){
			tot += totReciepts[downStreamCompanies[owner].owned[i]].amount;
		}
		return tot;
	}
	// 定义转让债权函数, debtTime可以设置要求获得指定还款时间上限的债权； 
	// 失败返回当前from所拥有的债权，成功返回0
	function TransferRight(uint from, uint to, uint amount, uint debtTime) public returns (uint){
		require(
			msg.sender == downStreamCompanies[from].self,
			"only debt owner can transferRight"
		);
		uint tamount = GetRight(from, debtTime);
		if(tamount < amount) return tamount;
		uint i;
		for(i = downStreamCompanies[from].owned.length - 1; int(i) >= 0 && totReciepts[downStreamCompanies[from].owned[i]].endTime > debtTime * 1000 + now; i--){
		    
		}
		for(;int(i) >= 0; i--){
			if(totReciepts[downStreamCompanies[from].owned[i]].amount < amount){
				totReciepts[downStreamCompanies[from].owned[i]].to = to;
				pushIdxWFTDebtTime(to, downStreamCompanies[from].owned[i]);
				amount -= totReciepts[downStreamCompanies[from].owned[i]].amount;
				popIdxWFTDebtTime(from, i);
			} 
			else if(totReciepts[downStreamCompanies[from].owned[i]].amount == amount){
				totReciepts[downStreamCompanies[from].owned[i]].to = to;
				pushIdxWFTDebtTime(to, downStreamCompanies[from].owned[i]);
				popIdxWFTDebtTime(from, i);
				amount = 0;
				break;
			}
			else{
				totReciepts[downStreamCompanies[from].owned[i]].amount -= amount;
				uint t = addReciept(to, amount, totReciepts[downStreamCompanies[from].owned[i]].endTime);
				inDebt -= amount;
				pushIdxWFTDebtTime(to, t);
				amount = 0;
				break;
			}
		}
		return 0;
	}
	// 定义利用应收账款向银行融资，具体实现为由银行获取该企业的应收账款和已获得融资，
	// 然后在链下达成融资并让双方在链上都确认了这一次融资，给企业加上已获得融资。
	function GetFinance(uint from) public returns(uint) {
		require(
			downStreamCompanies[from].fc == FinanceCondition.BANK_CHECKED,
			"only when fc is BANK_CHECKED can you get real finance"
		);
		return downStreamCompanies[from].financed;
	}
	function BankCheckFinance(uint from) public {
		require(
			msg.sender == bank,
			"only the bank can checkFinance"
		);
		downStreamCompanies[from].fc = FinanceCondition.BANK_CHECKED;
	}
	function CompanyAddFinance(uint from, uint amount) public {
		require(
			downStreamCompanies[from].fc == FinanceCondition.BANK_CHECKED,
			"only when fc is BANK_CHECKED can you add finance"
		);
		downStreamCompanies[from].fc = FinanceCondition.BANK_UNCHECKED;
		downStreamCompanies[from].financed += amount;
	}
	function CompanyPayFinance(uint from, uint amount) public {
		require(
			downStreamCompanies[from].fc == FinanceCondition.BANK_CHECKED,
			"only when fc is BANK_CHECKED can you add finance"
		);
		require(
			downStreamCompanies[from].financed >= amount,
			"well, you can't pay more than what you've financed."
		);
		downStreamCompanies[from].fc = FinanceCondition.BANK_UNCHECKED;
		downStreamCompanies[from].financed -= amount;
	}

	// 定义应收账款支付结算函数，具体实现为下游企业确认账单在链外被支付了
	function ConfirmPaied(uint to) public {
		require(
			msg.sender == downStreamCompanies[to].self,
			"only bill owner can change it to paied status"
		);
		uint i;
		for(i = 0; i < downStreamCompanies[to].owned.length && totReciepts[downStreamCompanies[to].owned[i]].endTime <= now; i++){
			totReciepts[downStreamCompanies[to].owned[i]].payed = true;
			totReciepts[downStreamCompanies[to].owned[i]].used = true;
			inDebt -= totReciepts[downStreamCompanies[to].owned[i]].amount;
		}
		for(uint j = i; j < downStreamCompanies[to].owned.length; j++){
			downStreamCompanies[to].owned[j - i] = downStreamCompanies[to].owned[j];
		}
		downStreamCompanies[to].owned.length -= i;
	}

	// 定义查找核心企业是否有到期未偿还的债权持有者
 	function CheckUnpaied() public {
		for(uint i = 1; i <= curId; i++){
 			unpaied[i] = false;
			for(uint j = 0; j < downStreamCompanies[i].owned.length; j++){
				if(totReciepts[downStreamCompanies[i].owned[j]].endTime <= now){
					unpaied[i] = true;
					break;
				}
			}
		}
	}
	
}

