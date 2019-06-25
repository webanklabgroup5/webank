package org.fisco.bcos.service;


import lombok.extern.slf4j.Slf4j;
import org.fisco.bcos.solidity.LAGCredit;
import org.fisco.bcos.constants.GasConstants;
import org.fisco.bcos.web3j.crypto.Credentials;
import org.fisco.bcos.web3j.protocol.Web3j;
import org.fisco.bcos.web3j.protocol.core.methods.response.TransactionReceipt;
import org.fisco.bcos.web3j.tx.gas.StaticGasProvider;
import org.springframework.beans.factory.annotation.Autowired;

import java.math.BigInteger;

@Slf4j
public class LagCreditService {

    public static LAGCredit deploy(Web3j web3j, Credentials credentials) {

        LAGCredit lagCredit = null;
        try {
            lagCredit = LAGCredit.deploy(web3j, credentials, new StaticGasProvider(
                    GasConstants.GAS_PRICE,GasConstants.GAS_LIMIT), new BigInteger("100000"), "LAGC", "LAG").send();
            log.info("LAGC address is {}", lagCredit.getContractAddress());
            return lagCredit;
        } catch (Exception e){
            log.error("deploy lagc contract fail: {}", e.getMessage());
        }
        return lagCredit;
    }

    public static LAGCredit load(Web3j web3j, Credentials credentials, String creditAddress){
        LAGCredit lagCredit = LAGCredit.load(creditAddress, web3j, credentials, new StaticGasProvider(GasConstants.GAS_PRICE, GasConstants.GAS_LIMIT));
        return lagCredit;
    }

    public static boolean transfer(Web3j web3j, Credentials credentials, String creditAddress, String to, BigInteger value){
        try {
            LAGCredit lagCredit = load(web3j,credentials,creditAddress);
            TransactionReceipt receipt = lagCredit.transfer(to, value).send();
            log.info("status: {}", receipt.getStatus());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return true;
    }

    public static String getAddress(Web3j web3j, Credentials credentials, String creditAddress) throws Exception{
        LAGCredit lagCredit = load(web3j,credentials,creditAddress);
        String balance = lagCredit.getAccountAddress().send();
        return balance;
    }

    public static long getBalanceByOwner(Web3j web3j, Credentials credentials, String creditAddress, String owner) throws Exception{
        LAGCredit lagCredit = load(web3j,credentials,creditAddress);
        BigInteger balance = lagCredit.balanceOf(owner).send();
        return balance.longValue();
    }

    public static long getTotalSupply(Web3j web3j, Credentials credentials, String creditAddress) throws Exception{
        LAGCredit lagCredit = load(web3j,credentials,creditAddress);
        BigInteger total = lagCredit.getTotalSupply().send();
        return total.longValue();
    }

}
