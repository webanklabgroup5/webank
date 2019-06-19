package org.fisco.bcos;

import static org.junit.Assert.assertTrue;

import java.math.BigInteger;

import org.fisco.bcos.constants.GasConstants;
import org.fisco.bcos.temp.HelloWorld;
import org.fisco.bcos.temp.LAGCredit;
import org.fisco.bcos.web3j.crypto.Credentials;
import org.fisco.bcos.web3j.protocol.Web3j;
import org.fisco.bcos.web3j.tx.gas.StaticGasProvider;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;

import jline.internal.Log;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class LAGCreditTest extends BaseTest {

    @Autowired private Web3j web3j;
    @Autowired private Credentials credentials;

    @Test 
    public void deloy() throws Exception {
    	// deploy contract
    	LAGCredit bookStore = LAGCredit.deploy(
    			web3j, credentials, 
				new StaticGasProvider(GasConstants.GAS_PRICE, GasConstants.GAS_LIMIT), 
				BigInteger.valueOf(1000), "SCUT", "simon")
    									.send();
    	if(bookStore != null) {
    		log.info("deploy LAGCredit successful! contract address is {}", bookStore.getContractAddress());
    		log.info("total supply is {}",bookStore.getTotalSupply().send());
    	}
    }
}
