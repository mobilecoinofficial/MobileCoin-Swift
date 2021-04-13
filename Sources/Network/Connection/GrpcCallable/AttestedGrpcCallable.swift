//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin
import SwiftProtobuf

enum AttestedCallError: Error {
    case aeadError(AeadError)
    case invalidInput(String)
}

extension AttestedCallError: CustomStringConvertible {
    var description: String {
        "Attested call error: " + {
            switch self {
            case .aeadError(let innerError):
                return "\(innerError)"
            case .invalidInput(let reason):
                return "Invalid input: \(reason)"
            }
        }()
    }
}

protocol AttestedGrpcCallable: GrpcCallable {
    associatedtype InnerRequestAad = ()
    associatedtype InnerRequest
    associatedtype InnerResponseAad = ()
    associatedtype InnerResponse

    func processRequest(
        requestAad: InnerRequestAad,
        request: InnerRequest,
        attestAkeCipher: AttestAke.Cipher
    ) -> Result<Request, AeadError>

    func processResponse(
        response: Response,
        attestAkeCipher: AttestAke.Cipher
    ) -> Result<(responseAad: InnerResponseAad, response: InnerResponse), AttestedConnectionError>
}

extension AttestedGrpcCallable where InnerRequestAad == (), InnerRequest == Request {
    func processRequest(
        requestAad: InnerRequestAad,
        request: InnerRequest,
        attestAkeCipher: AttestAke.Cipher
    ) -> Result<Request, AeadError> {
        .success(request)
    }
}

extension AttestedGrpcCallable where InnerResponseAad == (), InnerResponse == Response {
    func processResponse(response: Response, attestAkeCipher: AttestAke.Cipher)
        -> Result<(responseAad: InnerResponseAad, response: InnerResponse), AttestedConnectionError>
    {
        .success((responseAad: (), response: response))
    }
}

extension AttestedGrpcCallable
    where InnerRequestAad == (),
        Request == Attest_Message,
        InnerRequest: InfallibleDataSerializable
{
    func processRequest(
        requestAad: InnerRequestAad,
        request: InnerRequest,
        attestAkeCipher: AttestAke.Cipher
    ) -> Result<Attest_Message, AeadError> {
        let aad = Data()
        let plaintext = request.serializedDataInfallible

        return attestAkeCipher.encryptMessage(aad: aad, plaintext: plaintext)
    }
}

extension AttestedGrpcCallable
    where InnerResponseAad == (),
        Response == Attest_Message,
        InnerResponse: Message
{
    func processResponse(
        response: Attest_Message,
        attestAkeCipher: AttestAke.Cipher
    ) -> Result<(responseAad: InnerResponseAad, response: InnerResponse), AttestedConnectionError> {
        guard response.aad == Data() else {
            let errorMessage = "\(Self.self) received unexpected aad: " +
                "\(redacting: response.aad.base64EncodedString()), message: \(redacting: response)"
            logger.error(errorMessage)
            return .failure(.connectionError(.invalidServerResponse(errorMessage)))
        }

        return attestAkeCipher.decryptMessage(response)
            .mapError { _ in .attestationFailure() }
            .flatMap { plaintext in
                guard let response = try? InnerResponse(serializedData: plaintext) else {
                    let errorMessage = "Failed to deserialized attested message plaintext into " +
                        "\(InnerResponse.self). serializedData: " +
                        "\(redacting: plaintext.base64EncodedString())"
                    logger.error(errorMessage)
                    return .failure(.connectionError(.invalidServerResponse(errorMessage)))
                }
                return .success((responseAad: (), response: response))
            }
    }
}

extension AttestedGrpcCallable
    where InnerRequestAad: InfallibleDataSerializable,
        Request == Attest_Message,
        InnerRequest: InfallibleDataSerializable
{
    func processRequest(
        requestAad: InnerRequestAad,
        request: InnerRequest,
        attestAkeCipher: AttestAke.Cipher
    ) -> Result<Attest_Message, AeadError> {
        let aad = requestAad.serializedDataInfallible
        let plaintext = request.serializedDataInfallible

        return attestAkeCipher.encryptMessage(aad: aad, plaintext: plaintext)
    }
}

extension AttestedGrpcCallable
    where InnerResponseAad: Message,
        Response == Attest_Message,
        InnerResponse: Message
{
    func processResponse(
        response: Attest_Message,
        attestAkeCipher: AttestAke.Cipher
    ) -> Result<(responseAad: InnerResponseAad, response: InnerResponse), AttestedConnectionError> {
        attestAkeCipher.decryptMessage(response)
            .mapError { _ in .attestationFailure() }
            .flatMap { plaintext in
                guard let plaintextResponse = try? InnerResponse(serializedData: plaintext),
                      let responseAad = try? InnerResponseAad(serializedData: response.aad)
                else {
                    let errorMessage = "Failed to deserialized attested message plaintext using " +
                        "\(InnerResponse.self) and \(InnerResponseAad.self). serializedData: " +
                        "\(redacting: plaintext.base64EncodedString())"
                    logger.error(errorMessage)
                    return .failure(.connectionError(.invalidServerResponse(errorMessage)))
                }
                return .success((responseAad: responseAad, response: plaintextResponse))
            }
    }
}
