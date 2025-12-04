public with sharing class FanContentService {

    // ======================================================
    // 1) Obtener suscripción activa
    // ======================================================
    @AuraEnabled(cacheable=true)
    public static Subs_Fan__c getActiveSubscription(Id contactId) {

        if (contactId == null) {
            return null;
        }

        List<Subs_Fan__c> subs = [
            SELECT Id, Name, Estado__c, Nivel__c, Fecha_Renovacion__c, Contacto__c
            FROM Subs_Fan__c
            WHERE Contacto__c = :contactId
              AND Estado__c = 'Activa'
            LIMIT 1
        ];

        return subs.isEmpty() ? null : subs[0];
    }

    // ======================================================
    // 2) Noticias según el nivel
    // ======================================================
    @AuraEnabled(cacheable=true)
    public static List<Noticias__c> getNoticiasByNivel(Id contactId) {

        Subs_Fan__c sub = getActiveSubscription(contactId);

        if (sub == null) {
            return new List<Noticias__c>();
        }

        String nivel = sub.Nivel__c;
        List<String> allowed = getNivelesPermitidos(nivel);

        return [
            SELECT Id, Name, Titulo__c, Contenido__c, Nivel__c,
                   Imagen_URL__c, Fecha_Publicacion__c
            FROM Noticias__c
            WHERE Nivel__c IN :allowed
            ORDER BY Fecha_Publicacion__c DESC
            LIMIT 50
        ];
    }

    // ======================================================
    // 3) Productos según el nivel
    // ======================================================
    @AuraEnabled(cacheable=true)
    public static List<Producto_Fut_Connect__c> getProductosByNivel(Id contactId) {

        Subs_Fan__c sub = getActiveSubscription(contactId);

        if (sub == null) {
            return new List<Producto_Fut_Connect__c>();
        }

        String nivel = sub.Nivel__c;
        List<String> allowed = getNivelesPermitidos(nivel);

        return [
            SELECT Id, Name, Product_Name__c, List_Price__c, Nivel__c,
                   Active__c, Imagen_URL__c
            FROM Producto_Fut_Connect__c
            WHERE Active__c = TRUE
              AND Nivel__c IN :allowed
            ORDER BY List_Price__c ASC
            LIMIT 50
        ];
    }

    // ======================================================
    // 4) Lógica de niveles permitidos
    // ======================================================
    private static List<String> getNivelesPermitidos(String nivel) {

        if (nivel == 'Basico') {
            return new List<String>{ 'Basico' };
        }
        else if (nivel == 'Premium') {
            return new List<String>{ 'Basico', 'Premium' };
        }
        else if (nivel == 'VIP') {
            return new List<String>{ 'Basico', 'Premium', 'VIP' };
        }
        else {
            return new List<String>();
        }
    }

    // ======================================================
    // 5) NUEVO — BUSCADOR SOSL DE NOTICIAS (para LWC)
    // ======================================================
    @AuraEnabled
    public static List<Noticias__c> searchNoticias(String searchText) {

        if (String.isBlank(searchText)) {
            return new List<Noticias__c>();
        }

        // 🔍 Buscar en todos los campos indexados
        List<List<SObject>> results = [
            FIND :searchText IN ALL FIELDS
            RETURNING Noticias__c(
                Id, Name, Titulo__c, Contenido__c, Nivel__c,
                Imagen_URL__c, Fecha_Publicacion__c
            )
        ];

        List<Noticias__c> found = (List<Noticias__c>) results[0];

        return found != null ? found : new List<Noticias__c>();
    }
}