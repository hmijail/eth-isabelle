theory CallEx

imports
  Dispatcher
  "HOL-Eisbach.Eisbach"
  "../BlockFacts"
begin

\<comment>\<open>
squires $ cat call.sol 
pragma solidity ^0.4.24;

contract B {
	function f() pure public returns (uint256)
	{
		return 42;
	}
}

contract A {
    B b;
    uint256 v;

    constructor(address _b) public {
	b = B(_b);
	v = 0;
    }


    function callB() public returns (uint256)
    {
	    v = b.f();
    }

}
squires $ ./solc  call.sol --overwrite --bin -o res 
squires $ for f in res/*.bin ; do cat $f ; echo ; done
608060405234801561001057600080fd5b506040516020806101f383398101806040528101908080519060200190929190505050806000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055506000600181905550506101688061008b6000396000f300608060405260043610610041576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806344fd4fa014610046575b600080fd5b34801561005257600080fd5b5061005b610071565b6040518082815260200191505060405180910390f35b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff166326121ff06040518163ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401602060405180830381600087803b1580156100f857600080fd5b505af115801561010c573d6000803e3d6000fd5b505050506040513d602081101561012257600080fd5b8101908080519060200190929190505050600181905550905600a165627a7a72305820b098d684bc2516a3af5106f6efd38d926edb67ea42c065bd94a63e7e988f19980029
6080604052348015600f57600080fd5b5060a18061001e6000396000f300608060405260043610603f576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806326121ff0146044575b600080fd5b348015604f57600080fd5b506056606c565b6040518082815260200191505060405180910390f35b6000602a9050905600a165627a7a7230582056366c316c8eb1c2cb71b875b90a5eaf72d3069879bea637993dcf928cfb1cde0029
\<close>

definition A_addr :: "address" where
 "A_addr \<equiv> 0x42"
definition A_bytestr :: "byte list" where
 "A_bytestr \<equiv> bytes_of_hex_content ''608060405234801561001057600080fd5b506040516020806101f383398101806040528101908080519060200190929190505050806000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055506000600181905550506101688061008b6000396000f300608060405260043610610041576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806344fd4fa014610046575b600080fd5b34801561005257600080fd5b5061005b610071565b6040518082815260200191505060405180910390f35b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff166326121ff06040518163ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401602060405180830381600087803b1580156100f857600080fd5b505af115801561010c573d6000803e3d6000fd5b505050506040513d602081101561012257600080fd5b8101908080519060200190929190505050600181905550905600a165627a7a72305820b098d684bc2516a3af5106f6efd38d926edb67ea42c065bd94a63e7e988f19980029''"

definition B_addr :: "address" where
 "B_addr \<equiv> 0x43"
definition B_bytestr :: "byte list" where
 "B_bytestr \<equiv> bytes_of_hex_content ''6080604052348015600f57600080fd5b5060a18061001e6000396000f300608060405260043610603f576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806326121ff0146044575b600080fd5b348015604f57600080fd5b506056606c565b6040518082815260200191505060405180910390f35b6000602a9050905600a165627a7a7230582056366c316c8eb1c2cb71b875b90a5eaf72d3069879bea637993dcf928cfb1cde0029''"

definition
  bytestr_to_program :: "byte list \<Rightarrow> program" where
 "bytestr_to_program bytestr \<equiv> program_of_lst (parse_bytes bytestr)
                                              (\<lambda>xs i. if i < length xs then Some (xs ! nat i) else None)"

definition
  user :: address where
 "user = 0x88"

definition transaction_nonce :: w256 where
 "transaction_nonce \<equiv> 0x13"
definition
 "acc_bal = 0x1000000000000"
definition accounts :: "address \<Rightarrow> block_account"  where
 "accounts \<equiv> undefined(
    A_addr := \<lparr>   block_account_address = A_addr, 
                  block_account_storage = (\<lambda>_. 0),
                  block_account_code = bytestr_to_program A_bytestr,
                  block_account_balance = 0,
                  block_account_nonce = undefined,
                  block_account_exists = True,
                  block_account_hascode = True \<rparr> ,
    B_addr := \<lparr>   block_account_address = B_addr, 
                  block_account_storage = (\<lambda>_. 0),
                  block_account_code = bytestr_to_program B_bytestr,
                  block_account_balance = 0,
                  block_account_nonce = undefined,
                  block_account_exists = True,
                  block_account_hascode = True \<rparr>,
   user := \<lparr>   block_account_address = user, 
                  block_account_storage = (\<lambda>_. 0),
                  block_account_code = undefined,
                  block_account_balance = acc_bal,
                  block_account_nonce = transaction_nonce,
                  block_account_exists = True,
                  block_account_hascode = False \<rparr>)"

term start_transaction
term global_sem

definition
 "tr_gas_limit' \<equiv> 0x1000000"
definition tr :: transaction where
 "tr \<equiv> \<lparr> tr_from = user, tr_to = Some A_addr, tr_gas_limit = tr_gas_limit', tr_gas_price= 100, tr_value = 0, tr_nonce = transaction_nonce, tr_data = [] \<rparr>"

definition coinbase :: address where
 "coinbase \<equiv> 0x88888888888888"

definition "block_gaslimit' \<equiv> 0x1000000000000000"

definition bi :: block_info where
 "bi \<equiv> \<lparr> block_blockhash = undefined, block_coinbase = coinbase, block_timestamp = 0x6660000000, block_number= 100000000, block_difficulty = 0, block_gaslimit = block_gaslimit' \<rparr>"

lemmas addrs = A_addr_def B_addr_def user_def

schematic_goal start_trans:
 "start_transaction tr accounts bi = Continue ?s"
  apply (simp add: start_transaction_def Let_def)
  apply (simp add: tr_def)
  apply (rule conjI)
  
  apply (simp add: tr_def accounts_def addrs) 
   apply (clarsimp simp: calc_igas_def unat_arith_simps tr_gas_limit'_def)
  apply clarsimp
  apply (rule conjI)
  apply (simp add: tr_def accounts_def addrs) 
   apply (clarsimp simp: calc_igas_def unat_arith_simps homestead_block_def )
   apply (clarsimp simp: bi_def)
   apply (clarsimp simp: block_gaslimit'_def tr_gas_limit'_def)
  apply clarsimp
  apply (rule conjI)
  apply (simp add: tr_def accounts_def addrs) 
   apply (clarsimp simp:  unat_arith_simps homestead_block_def )
   apply (clarsimp simp: bi_def)
   apply (clarsimp simp: acc_bal_def tr_gas_limit'_def)
  apply clarsimp
  apply (rule conjI)
   apply (clarsimp simp: accounts_def)
  apply (clarsimp simp: Let_def)
  apply (rule refl)
  done

lemma addrs_uniq:
 "A_addr \<noteq> user"
 "B_addr \<noteq> user"
 "A_addr \<noteq> B_addr"
  by (simp add: addrs)+

lemma update_world_simp:
  "x \<noteq> y
  \<Longrightarrow> (update_world accs x (accs x \<lparr>block_account_nonce := n, block_account_balance := m\<rparr>) y) = accs y"
  by (simp add: update_world_def)


lemma build_cctx_update_world:
  "(build_cctx0 (update_world accounts user
               (accounts user
                \<lparr>block_account_nonce := transaction_nonce + 1,
                   block_account_balance := block_account_balance (accounts user) - 0x64 * tr_gas_limit'\<rparr>)
               A_addr)) = \<lparr>cctx_program = bytestr_to_program A_bytestr, cctx_this = A_addr, cctx_hash_filter = \<lambda>x. True\<rparr>"
  apply (subst update_world_simp, simp add: addrs_uniq[symmetric])
  apply (simp add: accounts_def addrs_uniq)
  apply (simp add: build_cctx0_def)
  done

lemma
" program_sem_t
        \<lparr>cctx_program = bytestr_to_program A_bytestr, cctx_this = A_addr, cctx_hash_filter = \<lambda>x. True\<rparr> net
        (InstructionContinue
          \<lparr>vctx_stack = [], vctx_memory = empty_memory, vctx_memory_usage = 0,
             vctx_storage = block_account_storage (accounts A_addr), vctx_pc = 0,
             vctx_balance =
               \<lambda>addr.
                  block_account_balance
                   (update_world
                     (update_world accounts user
                       (accounts user
                        \<lparr>block_account_nonce := transaction_nonce + 1,
                           block_account_balance := block_account_balance (accounts user) - 0x64000000\<rparr>))
                     A_addr (accounts A_addr) addr),
             vctx_caller = user, vctx_value_sent = 0, vctx_data_sent = [],
             vctx_storage_at_call = block_account_storage (accounts A_addr),
             vctx_balance_at_call =
               \<lambda>addr.
                  block_account_balance
                   (update_world
                     (update_world accounts user
                       (accounts user
                        \<lparr>block_account_nonce := transaction_nonce + 1,
                           block_account_balance := block_account_balance (accounts user) - 0x64000000\<rparr>))
                     A_addr (accounts A_addr) addr),
             vctx_origin = user,
             vctx_ext_program =
               \<lambda>addr.
                  block_account_code
                   (update_world
                     (update_world accounts user
                       (accounts user
                        \<lparr>block_account_nonce := transaction_nonce + 1,
                           block_account_balance := block_account_balance (accounts user) - 0x64000000\<rparr>))
                     A_addr (accounts A_addr) addr),
             vctx_block =
               \<lparr>block_blockhash = undefined, block_coinbase = coinbase, block_timestamp = 0x6660000000,
                  block_number = 0x5F5E100, block_difficulty = 0, block_gaslimit = block_gaslimit'\<rparr>,
             vctx_gas = 16756216,
             vctx_account_existence =
               \<lambda>addr.
                  block_account_exists
                   (update_world
                     (update_world accounts user
                       (accounts user
                        \<lparr>block_account_nonce := transaction_nonce + 1,
                           block_account_balance := block_account_balance (accounts user) - 0x64000000\<rparr>))
                     A_addr (accounts A_addr) addr),
             vctx_touched_storage_index = [], vctx_logs = [], vctx_refund = 0, vctx_gasprice = 0x64\<rparr>) =
       InstructionToEnvironment x21 x22 x23"
  oops

lemma A_calls_B_spec:
 "triple_sem_t net P (undefined A_bytestr) Q"
  sorry

lemma
  "sint (block_number bi) \<ge> homestead_block \<Longrightarrow> 
  global_sem net (case start_transaction tr accounts bi of Continue x \<Rightarrow> x) = Some v"
  apply clarsimp

  apply (rule context_conjI)
   apply (clarsimp simp: start_trans)
   apply (clarsimp simp: get_vctx_gas_def create_env_def)
   apply (clarsimp simp: calc_igas_def tr_gas_limit'_def)
  apply simp  
  apply (clarsimp simp add: Let_def split: instruction_result.splits)
  apply (rule conjI)
  apply (clarsimp split: global_state.split)
   apply (simp (no_asm) add: start_trans create_env_def)
  apply clarsimp
   apply (clarsimp simp: build_cctx_update_world)
   apply (subst update_world_simp, fastforce simp: addrs_uniq[symmetric])+
  apply (rule conjI)
    apply clarsimp
    apply (clarsimp simp: global_step_def)
  apply (clarsimp simp: envstep_def Let_def)
    apply (clarsimp simp: tr_gas_limit'_def calc_igas_def bi_def homestead_block_def)
  apply (clarsimp simp add: program_sem_t_no_gas_not_continuing split: instruction_result.splits)
  apply (clarsimp simp: program_sem_t.simps vctx_next_instruction_def)
  using A_calls_B_spec[simplified]
    apply (case_tac "global_step net _ ")
  oops

end
