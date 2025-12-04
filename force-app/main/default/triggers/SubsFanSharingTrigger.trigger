trigger SubsFanSharingTrigger on Subs_Fan__c (after insert, after update) {
    List<Subs_Fan__Share> shares = new List<Subs_Fan__Share>();

    for (Subs_Fan__c s : Trigger.new) {
        // Evita ejecutar si Contacto__c está vacío
        if (s.Contacto__c == null) continue;

        // Crea registro de sharing
        Subs_Fan__Share sh = new Subs_Fan__Share();
        sh.ParentId = s.Id;                        // Registro Subs_Fan__c
        sh.UserOrGroupId = s.Contacto__c;          // Contacto relacionado (fan)
        sh.AccessLevel = 'Read';                   // Solo lectura
        sh.RowCause = Schema.Subs_Fan__Share.RowCause.Manual; 
        shares.add(sh);
    }

    if (!shares.isEmpty()) {
        insert shares;
    }
}