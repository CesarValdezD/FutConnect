@RestResource(urlMapping='/FutConnect/Noticias/*')
global with sharing class FutConnectNoticiasAPI {

    // ======================================
    // GET → Obtener noticias por nivel
    // URL: /services/apexrest/FutConnect/Noticias?nivel=VIP
    // ======================================
    @HttpGet
    global static List<Noticias__c> getNoticias() {

        RestRequest req = RestContext.request;
        String nivel = req.params.get('nivel');

        if (String.isBlank(nivel)) {
            throw new AuraHandledException('Parámetro "nivel" requerido');
        }

        return [
            SELECT Id, Titulo__c, Contenido__c, Nivel__c, Fecha_Publicacion__c
            FROM Noticias__c
            WHERE Nivel__c = :nivel
            ORDER BY Fecha_Publicacion__c DESC
            LIMIT 20
        ];
    }


    // ======================================
    // POST → Crear una noticia nueva
    // ======================================
    @HttpPost
    global static Noticias__c createNoticia() {

        RestRequest req = RestContext.request;
        String body = req.requestBody.toString();

        // Convert JSON → Objeto
        Noticias__c n = (Noticias__c) JSON.deserialize(body, Noticias__c.class);

        insert n;

        return n;
    }
}