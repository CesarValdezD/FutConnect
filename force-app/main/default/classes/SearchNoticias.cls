public with sharing class SearchNoticias {
    @AuraEnabled(cacheable=true)
    public static List<Noticias__c> search(String texto) {

        // Si el texto viene vacío, regresamos lista vacía
        if (String.isBlank(texto)) {
            return new List<Noticias__c>();
        }

        // SOSL para buscar en todos los campos
        List<List<SObject>> results = [
            FIND :texto IN ALL FIELDS
            RETURNING Noticias__c(Id, Titulo__c, Contenido__c, Nivel__c)
        ];

        // results[0] contiene la lista de Noticias__c encontradas
        return (List<Noticias__c>) results[0];
    }
}