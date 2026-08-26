//
//  Copyright (c) 2020-2026 MobileCoin. All rights reserved.
//

import Foundation

extension TransactionBuilder {

    /// Derives the payload and change outputs a transaction built with
    /// `context` would produce, without adding inputs or building one.
    ///
    /// Building the same transaction later with the same `context.rngSeed`
    /// yields the same keys: inputs are added before the seeded RNG exists and
    /// consume none of it, so they cannot move the outputs. That is also why
    /// no balance is required here — inputs are what need funds.
    ///
    /// Takes only what a key depends on. A TxOut public key is `r * D`: `r`
    /// comes from the seed and the order of the builder's draws, `D` from the
    /// recipient's subaddress. Nothing else reaches either — the builder draws
    /// exactly twice per output, for the fog hint and for `r`, and everything
    /// after that is handed the key rather than the RNG. Amounts, fees and
    /// memos are therefore not parameters; the zeros and defaults used here
    /// produce the same keys as any real transaction, which
    /// `TxOutContextsDerivationTests` pins.
    static func txOutContexts(
        context: TransactionBuilder.Context,
        recipient: PublicAddress
    ) -> Result<(payload: TxOutContext, change: TxOutContext), TransactionBuilderError> {
        let builder: TransactionBuilder
        switch makeBuilder(context: context) {
        case .failure(let error):
            return .failure(error)
        case .success(let made):
            builder = made
        }

        // Zero, because no amount reaches a draw. Both outputs use the fee's
        // token id so the builder's mixed-token check cannot trip on values
        // that do not describe a real transaction anyway.
        let zero = Amount(0, in: context.fee.tokenId)
        let possibleTransaction = PossibleTransaction(
            [TransactionOutput(recipient: recipient, amount: zero)],
            zero)

        let (payloadContexts, changeContext) = addOutputs(
            context: context,
            builder: builder,
            possibleTransaction: possibleTransaction,
            rng: MobileCoinChaCha20Rng(rngSeed: context.rngSeed))

        return payloadContexts.collectResult().flatMap { payloads in
            guard let payload = payloads.first else {
                return .failure(.invalidInput("No payload output produced"))
            }
            return changeContext.map { change in (payload: payload, change: change) }
        }
    }

}
