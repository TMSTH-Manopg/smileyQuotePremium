PROCEDURE publishpremium_Response:

    DEFINE VARIABLE httpClient   AS System.Net.WebClient NO-UNDO.
    DEFINE VARIABLE webResponse  AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE cResponse    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cError       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cURL         AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lcRequest    AS LONGCHAR NO-UNDO.

    DEFINE VARIABLE oBody AS JsonObject NO-UNDO.
    DEFINE VARIABLE oJson AS JsonObject NO-UNDO.
    DEFINE VARIABLE myParser AS ObjectModelParser NO-UNDO.

    /* ============================= */
    /* 1. Build JSON Request */
    /* ============================= */
    oBody = NEW JsonObject().
    oBody:Add("status", "success").
    oBody:Add("transactionId", "12345").

    lcRequest = oBody:ToString().

    /* ============================= */
    /* 2. Config URL */
    /* ============================= */
    ASSIGN 
        cURL = "https://your-dotnet-api/webhook".

    /* ============================= */
    /* 3. Setup HTTP Client */
    /* ============================= */
    System.Net.ServicePointManager:SecurityProtocol = 
        System.Net.SecurityProtocolType:Tls12.

    httpClient = NEW System.Net.WebClient().
    httpClient:Encoding = System.Text.Encoding:UTF8.

    httpClient:Headers:Add("Content-Type", "application/json").
    httpClient:Headers:Add("Accept", "application/json").

    /* ? Timeout (สำคัญมาก) */
    httpClient:BaseAddress = cURL.

    /* ============================= */
    /* 4. Call API */
    /* ============================= */

    DO ON ERROR UNDO, LEAVE:

        webResponse = httpClient:UploadString(cURL, "POST", lcRequest).

    END.

    /* ============================= */
    /* 5. Handle Error */
    /* ============================= */
    IF ERROR-STATUS:ERROR THEN DO:

        cError = ERROR-STATUS:GET-MESSAGE(1).

        OUTPUT TO "D:\Smileyquote\Log\webhook_error.log" APPEND.
        PUT UNFORMATTED
            STRING(TODAY,"99/99/9999") + " " + STRING(TIME,"HH:MM:SS")
            + " ERROR: " + cError SKIP.
        OUTPUT CLOSE.

        RETURN.
    END.

    /* ============================= */
    /* 6. Log Response */
    /* ============================= */
    OUTPUT TO "D:\Smileyquote\Log\webhook_response.log" APPEND.
    PUT UNFORMATTED
        STRING(TODAY,"99/99/9999") + " " + STRING(TIME,"HH:MM:SS")
        + " REQUEST: " lcRequest SKIP
        + " RESPONSE: " webResponse SKIP(1).
    OUTPUT CLOSE.

    /* ============================= */
    /* 7. Parse JSON Response */
    /* ============================= */
    myParser = NEW ObjectModelParser().

    oJson = CAST(myParser:Parse(webResponse), JsonObject) NO-ERROR.

    IF VALID-OBJECT(oJson) THEN DO:
        cResponse = oJson:GetCharacter("status") NO-ERROR.
    END.

    /* ============================= */
    /* 8. Final Result Check */
    /* ============================= */
    IF cResponse <> "success" THEN DO:
        /* log business error */
        OUTPUT TO "D:\Smileyquote\Log\webhook_business_error.log" APPEND.
        PUT UNFORMATTED
            "Invalid response: " webResponse SKIP.
        OUTPUT CLOSE.
    END.

    httpClient:Dispose().
    DELETE OBJECT httpClient.

END PROCEDURE.
