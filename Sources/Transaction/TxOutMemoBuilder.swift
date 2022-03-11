//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

class TxOutMemoBuilder {
    let ptr: OpaquePointer

    private init(
        ptr: OpaquePointer
    ) {
        self.ptr = ptr
    }
    
}

final class SenderAndDestinationMemoBuilder : TxOutMemoBuilder {
    init(
        accountKey: AccountKey
    ) {
//        super.init(ptr: OpaquePointer())
    }
}

final class DefaultMemoBuilder : TxOutMemoBuilder {
    init() {
//        super.init(ptr: OpaquePointer())
    }
}

final class SenderPaymentRequestAndDestinationMemoBuilder : TxOutMemoBuilder {
    init() {
//        super.init(ptr: OpaquePointer())
    }
}

/**
 public class TxOutMemoBuilder extends Native {
   private TxOutMemoBuilder(@NonNull AccountKey accountKey, UnsignedLong paymentRequestId) throws TransactionBuilderException {
     try {
       init_jni_with_sender_payment_request_and_destination_rth_memo(
           accountKey,
           paymentRequestId.longValue()
       );
     } catch (Exception exception) {
       throw new TransactionBuilderException("Unable to create TxOutMemoBuilder", exception);
     }
   }

   private TxOutMemoBuilder(@NonNull AccountKey accountKey) throws TransactionBuilderException {
     try {
       init_jni_with_sender_and_destination_rth_memo(accountKey);
     } catch (Exception exception) {
       throw new TransactionBuilderException("Unable to create TxOutMemoBuilder", exception);
     }
   }

   private TxOutMemoBuilder() throws TransactionBuilderException {
     try {
       init_jni_with_default_rth_memo();
     } catch (Exception exception) {
       throw new TransactionBuilderException("Unable to create TxOutMemoBuilder", exception);
     }
   }

   private native void init_jni_with_sender_and_destination_rth_memo(@NonNull AccountKey accountKey);

   private native void init_jni_with_sender_payment_request_and_destination_rth_memo(@NonNull AccountKey accountKey, long paymentRequestId);

   private native void init_jni_with_default_rth_memo();

 }
 */
