//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest
@testable import MobileCoin
@testable import LibMobileCoin

class TxOutMemoIntegrationTests: XCTestCase {
    
    func testPerformanceExample() throws {
        
    }

}

extension TransactionBuilder {
    enum Fixtures {}
}

extension TransactionBuilder.Fixtures {
    struct Init {
        // The 'real index' corresponds to the index of the TxOut in a Ring's TxOUt list that actually
        // belongs ot the spender and is being used in the transaction.
        let realIndex = 3;

//        let senderAccountKey: AccountKey
//        let receiverAccountKey: AccountKey
//
        init() throws {
//            self.senderAccountKey = try Self.makeAccountKey(hex: Self.senderAccountKeyHex)
//            self.receiverAccountKey = try Self.makeAccountKey(hex: Self.receiverAccountKeyHex)
            
        }
    }
    
    struct DefaultNotSet {

        init() throws {
        }
    }
}

/**
 @RunWith(AndroidJUnit4.class)
 public class TxOutMemoIntegrationTest {

   @Test
   public void buildTransaction_senderAndDestinationMemoBuilder_buildsCorrectSenderMemo() throws Exception {
     TxOutMemoBuilder txOutMemoBuilder = TxOutMemoBuilder
         .createSenderAndDestinationRTHMemoBuilder(senderAccountKey);
     TxOut realTxOut = txOuts.get(realIndex);
     transactionBuilder = new TransactionBuilder(fogResolver, txOutMemoBuilder, 2);

     RistrettoPrivate onetimePrivateKey = Util.recoverOnetimePrivateKey(
         realTxOut.getPubKey(),
         realTxOut.getTargetKey(),
         senderAccountKey
     );
     transactionBuilder
         .addInput(txOuts, txOutMembershipProofs, realIndex, onetimePrivateKey,
             senderAccountKey.getViewKey());
     long fee = 1L;
     transactionBuilder.setFee(fee);
     transactionBuilder.setTombstoneBlockIndex(UnsignedLong.valueOf(2000));
     BigInteger sentTxOutValue = BigInteger.ONE;

     transactionBuilder.addOutput(sentTxOutValue, recipientAccountKey.getPublicAddress(), null);
     BigInteger realTxOutValue = realTxOut.getAmount()
         .unmaskValue(senderAccountKey.getViewKey(), realTxOut.getPubKey());
     BigInteger changeValue = realTxOutValue.subtract(BigInteger.valueOf(fee))
         .subtract(sentTxOutValue);
     transactionBuilder.addChangeOutput(changeValue, senderAccountKey, null);
     Transaction transaction = transactionBuilder.build();

     List<MobileCoinAPI.TxOut> outputsList = transaction.toProtoBufObject().getPrefix()
         .getOutputsList();
     TxOut txOut1 = TxOut.fromProtoBufObject(outputsList.get(0));
     TxOut txOut2 = TxOut.fromProtoBufObject(outputsList.get(1));

     TxOut sentTxOut;
     try {
       txOut1.getAmount().unmaskValue(recipientAccountKey.getViewKey(), txOut1.getPubKey());
       sentTxOut = txOut1;
     } catch(Exception e) {
       sentTxOut = txOut2;
     }

     byte[] sentMemoPayload = sentTxOut.decryptMemoPayload(recipientAccountKey);

     AddressHash senderAddressHash = senderAccountKey.getPublicAddress().calculateAddressHash();
     SenderMemo senderMemo = (SenderMemo) TxOutMemoParser
         .parseTxOutMemo(sentMemoPayload, recipientAccountKey, sentTxOut);
     assertEquals(senderAddressHash, senderMemo.getUnvalidatedAddressHash());
     SenderMemoData senderMemoData = senderMemo
         .getSenderMemoData(senderAccountKey.getPublicAddress(), recipientAccountKey.getDefaultSubAddressViewKey());

     assertEquals(senderAddressHash, senderMemoData.getAddressHash());
   }

   @Test
   public void buildTransaction_senderAndDestinationMemoBuilder_buildsCorrectDestinationMemo() throws Exception {
     TxOutMemoBuilder txOutMemoBuilder = TxOutMemoBuilder
         .createSenderAndDestinationRTHMemoBuilder(senderAccountKey);
     transactionBuilder = new TransactionBuilder(fogResolver, txOutMemoBuilder, 2);

     TxOut realTxOut = txOuts.get(realIndex);

     RistrettoPrivate onetimePrivateKey = Util.recoverOnetimePrivateKey(
         realTxOut.getPubKey(),
         realTxOut.getTargetKey(),
         senderAccountKey
     );

     transactionBuilder
         .addInput(txOuts, txOutMembershipProofs, realIndex, onetimePrivateKey,
             senderAccountKey.getViewKey());
     long fee = 1L;
     transactionBuilder.setFee(fee);
     transactionBuilder.setTombstoneBlockIndex(UnsignedLong.valueOf(2000));
     BigInteger txValue = BigInteger.ONE;

     transactionBuilder.addOutput(txValue, recipientAccountKey.getPublicAddress(), null);
     BigInteger realTxOutValue = realTxOut.getAmount()
         .unmaskValue(senderAccountKey.getViewKey(), realTxOut.getPubKey());
     BigInteger changeValue = realTxOutValue.subtract(BigInteger.valueOf(fee)).subtract(txValue);
     transactionBuilder.addChangeOutput(changeValue, senderAccountKey, null);
     Transaction transaction = transactionBuilder.build();

     List<MobileCoinAPI.TxOut> outputsList = transaction.toProtoBufObject().getPrefix()
         .getOutputsList();
     TxOut txOut1 = TxOut.fromProtoBufObject(outputsList.get(0));
     TxOut txOut2 = TxOut.fromProtoBufObject(outputsList.get(1));

     TxOut changeTxOut;
     try {
       txOut1.getAmount()
           .unmaskValue(senderAccountKey.getViewKey(), txOut1.getPubKey());
       changeTxOut = txOut1;
     } catch(Exception e) {
       changeTxOut = txOut2;
     }
     byte[] changeMemoPayload = changeTxOut.decryptMemoPayload(senderAccountKey);

     DestinationMemo destinationMemo = (DestinationMemo) TxOutMemoParser
         .parseTxOutMemo(changeMemoPayload, senderAccountKey, changeTxOut);
     DestinationMemoData destinationMemoData = destinationMemo.getDestinationMemoData();
     UnsignedLong totalOutlay = UnsignedLong.valueOf(fee).add(UnsignedLong.valueOf(txValue));

     assertEquals(UnsignedLong.valueOf(fee), destinationMemoData.getFee());
     assertEquals(totalOutlay, destinationMemoData.getTotalOutlay());
     AddressHash recipientAddressHash = recipientAccountKey.getPublicAddress()
         .calculateAddressHash();
     assertEquals(recipientAddressHash, destinationMemoData.getAddressHash());
   }

   @Test
   public void buildTransaction_senderWithPaymentRequestAndDestinationMemoBuilder_buildsCorrectSenderWithPaymentRequestMemo() throws Exception {
     UnsignedLong paymentRequestId = UnsignedLong.valueOf(301);
     TxOutMemoBuilder txOutMemoBuilder = TxOutMemoBuilder
         .createSenderPaymentRequestAndDestinationRTHMemoBuilder(senderAccountKey, paymentRequestId);
     TxOut realTxOut = txOuts.get(realIndex);
     transactionBuilder = new TransactionBuilder(fogResolver, txOutMemoBuilder, 2);

     RistrettoPrivate onetimePrivateKey = Util.recoverOnetimePrivateKey(
         realTxOut.getPubKey(),
         realTxOut.getTargetKey(),
         senderAccountKey
     );
     transactionBuilder
         .addInput(txOuts, txOutMembershipProofs, realIndex, onetimePrivateKey,
             senderAccountKey.getViewKey());
     long fee = 1L;
     transactionBuilder.setFee(fee);
     transactionBuilder.setTombstoneBlockIndex(UnsignedLong.valueOf(2000));
     BigInteger sentTxOutValue = BigInteger.ONE;

     transactionBuilder.addOutput(sentTxOutValue, recipientAccountKey.getPublicAddress(), null);
     BigInteger realTxOutValue = realTxOut.getAmount()
         .unmaskValue(senderAccountKey.getViewKey(), realTxOut.getPubKey());
     BigInteger changeValue = realTxOutValue.subtract(BigInteger.valueOf(fee))
         .subtract(sentTxOutValue);
     transactionBuilder.addChangeOutput(changeValue, senderAccountKey, null);
     Transaction transaction = transactionBuilder.build();

     List<MobileCoinAPI.TxOut> outputsList = transaction.toProtoBufObject().getPrefix()
         .getOutputsList();
     TxOut txOut1 = TxOut.fromProtoBufObject(outputsList.get(0));
     TxOut txOut2 = TxOut.fromProtoBufObject(outputsList.get(1));

     TxOut sentTxOut;
     try {
       txOut1.getAmount().unmaskValue(recipientAccountKey.getViewKey(), txOut1.getPubKey());
       sentTxOut = txOut1;
     } catch(Exception e) {
       sentTxOut = txOut2;
     }

     byte[] sentWithPaymentRequestMemoPayload = sentTxOut.decryptMemoPayload(recipientAccountKey);

     AddressHash senderAddressHash = senderAccountKey.getPublicAddress().calculateAddressHash();
     SenderWithPaymentRequestMemo senderWithPaymentRequestMemo = (SenderWithPaymentRequestMemo) TxOutMemoParser
         .parseTxOutMemo(sentWithPaymentRequestMemoPayload, recipientAccountKey, sentTxOut);
     assertEquals(senderAddressHash, senderWithPaymentRequestMemo.getUnvalidatedAddressHash());
     SenderWithPaymentRequestMemoData senderWithPaymentRequestMemoData = senderWithPaymentRequestMemo
         .getSenderWithPaymentRequestMemoData(senderAccountKey.getPublicAddress(), recipientAccountKey.getDefaultSubAddressViewKey());

     assertEquals(senderAddressHash, senderWithPaymentRequestMemoData.getAddressHash());
     assertEquals(paymentRequestId, senderWithPaymentRequestMemoData.getPaymentRequestId());
   }

   @Test
   public void buildTransaction_senderAndDestinationMemoBuilder_txBuidlerRespectsBlockVersion() throws Exception {
     TxOutMemoBuilder txOutMemoBuilder = TxOutMemoBuilder
             .createSenderAndDestinationRTHMemoBuilder(senderAccountKey);
     TxOut realTxOut = txOuts.get(realIndex);
     transactionBuilder = new TransactionBuilder(fogResolver, txOutMemoBuilder, 1);

     RistrettoPrivate onetimePrivateKey = Util.recoverOnetimePrivateKey(
             realTxOut.getPubKey(),
             realTxOut.getTargetKey(),
             senderAccountKey
     );
     transactionBuilder
             .addInput(txOuts, txOutMembershipProofs, realIndex, onetimePrivateKey,
                     senderAccountKey.getViewKey());
     long fee = 1L;
     transactionBuilder.setFee(fee);
     transactionBuilder.setTombstoneBlockIndex(UnsignedLong.valueOf(2000));
     BigInteger sentTxOutValue = BigInteger.ONE;

     transactionBuilder.addOutput(sentTxOutValue, recipientAccountKey.getPublicAddress(), null);
     BigInteger realTxOutValue = realTxOut.getAmount()
             .unmaskValue(senderAccountKey.getViewKey(), realTxOut.getPubKey());
     BigInteger changeValue = realTxOutValue.subtract(BigInteger.valueOf(fee))
             .subtract(sentTxOutValue);
     transactionBuilder.addChangeOutput(changeValue, senderAccountKey, null);
     Transaction transaction = transactionBuilder.build();

     List<MobileCoinAPI.TxOut> outputsList = transaction.toProtoBufObject().getPrefix()
             .getOutputsList();
     TxOut txOut1 = TxOut.fromProtoBufObject(outputsList.get(0));
     TxOut txOut2 = TxOut.fromProtoBufObject(outputsList.get(1));

     TxOut sentTxOut;
     try {
       txOut1.getAmount().unmaskValue(recipientAccountKey.getViewKey(), txOut1.getPubKey());
       sentTxOut = txOut1;
     } catch(Exception e) {
       sentTxOut = txOut2;
     }

     byte[] sentMemoPayload = sentTxOut.decryptMemoPayload(recipientAccountKey);

     TxOutMemo unsetMemo = TxOutMemoParser
             .parseTxOutMemo(sentMemoPayload, recipientAccountKey, sentTxOut);

     assertEquals(TxOutMemoType.NOT_SET, unsetMemo.getTxOutMemoType());
   }

 }

 return result
 **/
