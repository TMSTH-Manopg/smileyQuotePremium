USING OpenEdge.Net.HTTP.ClientBuilder.
USING OpenEdge.Net.HTTP.IHttpClient.
USING OpenEdge.Net.HTTP.RequestBuilder.
USING OpenEdge.Net.HTTP.IHttpResponse.

DEFINE VARIABLE oClient AS IHttpClient NO-UNDO.
DEFINE VARIABLE oRequest AS IHttpRequest NO-UNDO.
DEFINE VARIABLE oResponse AS IHttpResponse NO-UNDO.

DEFINE VARIABLE lcJson AS LONGCHAR NO-UNDO.

lcJson = '
{
   "transactionId":"TXN001",
   "status":"SUCCESS",
   "message":"Completed",
   "referenceNo":"REF123"
}'.

oClient = ClientBuilder:Build().

oRequest = RequestBuilder:Post("https://your-api/api/webhook/progress-result")
    :ContentType("application/json")
    :AcceptJson()
    :Request.

oRequest:SetBody(lcJson).

oResponse = oClient:Execute(oRequest).

MESSAGE
    STRING(oResponse:StatusCode)
VIEW-AS ALERT-BOX.
