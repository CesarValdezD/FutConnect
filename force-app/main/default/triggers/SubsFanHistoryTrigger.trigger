trigger SubsFanHistoryTrigger on Subs_Fan__c (after update) {

    List<Subscription_History__c> recordsToInsert = new List<Subscription_History__c>();

    for (Integer i = 0; i < Trigger.new.size(); i++) {
        Subs_Fan__c newRec = Trigger.new[i];
        Subs_Fan__c oldRec = Trigger.old[i];

        // Verificar si el Nivel cambió
        if (newRec.Nivel__c != oldRec.Nivel__c) {
            
            recordsToInsert.add(new Subscription_History__c(
                Suscripcion__c = newRec.Id,
                Nivel_Anterior__c = oldRec.Nivel__c,
                Nivel_Nuevo__c = newRec.Nivel__c,
                Fecha_Cambio__c = System.now()
            ));
        }
    }

    if (!recordsToInsert.isEmpty()) {
        insert recordsToInsert;
    }
}