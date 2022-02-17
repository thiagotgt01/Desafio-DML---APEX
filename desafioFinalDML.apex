
public static Set<Id> idAccountsForEvents(){
Set<Id> idAccounts = new Set<Id>{};
List<Account> accountList = [
        SELECT Id
        FROM Account
    ];
    
for(Integer count = 0; count < accountList.size();count++){
    
    Account accountGet = accountList.get(count);
    
    idAccounts.add(accountGet.Id);
    
}
    System.debug(' idAccountsForEvents() =>>'+idAccounts);
return idAccounts;
}
//Invoca Todos os ID Account

//idAccountsForEvents();


public static List<Evento__c> checkEvents(Set<Id> accountIdSet){
    
    List<Evento__c> eventoListOnlyComercial = [
        SELECT Id,Name,Status__c,Tipo__c, Conta__r.Id,Ativo__c,Data__c,Descricao__c,Localidade__r.Id
        FROM Evento__c
        WHERE Status__c = 'Adiado' AND Tipo__c = 'Comercial' AND Conta__r.Id =:accountIdSet
    ];

    List<Evento__c> eventoListEverybody = [
        SELECT Id,Name,Status__c,Tipo__c,Data__c
        FROM Evento__c
        WHERE Status__c = 'Adiado' AND Tipo__c != 'Comercial' AND Conta__r.Id =:accountIdSet
    ];

    List<Evento__c> returnList = new List<Evento__c>();
    
    System.debug(' eventoListOnlyComercial1 ==> '+eventoListOnlyComercial);
    System.debug(' eventoListEverybody ==> '+eventoListEverybody);
    Date today = Date.today();
    // atualizando valores do evento legado
    for(Integer count=0;count <eventoListOnlyComercial.size();count++ ){
        

        Evento__c eventoGetComercial = eventoListOnlyComercial.get(count);
        eventoGetComercial.Ativo__c = false;
        returnList.add(eventoGetComercial);

    System.debug(' eventoGetComercial ==>> '+eventoGetComercial);
        
        
        //criação de copias dos eventos legados
        Evento__c eventoGetComercialMakeEvent = new Evento__c();
        eventoGetComercialMakeEvent = eventoGetComercial;
        /*
		eventoGetComercialMakeEvent.Ativo__c = true;
        eventoGetComercialMakeEvent.Status__c = 'Pendente';
        eventoGetComercialMakeEvent.Data__c = today;*/

    returnList.add(new Evento__c (
        Name = (eventoGetComercialMakeEvent.Name+' Novo'),
        Conta__c = eventoGetComercialMakeEvent.Conta__r.Id,
        Ativo__c = true,
        Tipo__c = eventoGetComercialMakeEvent.Tipo__c,
        Status__c = 'Pendente',
        Data__c =  today,
        Descricao__c = eventoGetComercialMakeEvent.Descricao__c,
        Localidade__c = eventoGetComercialMakeEvent.Localidade__r.Id

    ));

System.debug(' eventoGetComercialMakeEvent ==>> '+eventoGetComercialMakeEvent);
    }

    for(Integer count = 0; count < eventoListEverybody.size();count++){

        Evento__c eventoGetEverybodyMakeEvent = eventoListEverybody.get(count);
        eventoGetEverybodyMakeEvent.Data__c = today;
        returnList.add(eventoGetEverybodyMakeEvent);


System.debug(' eventoGetEverybodyMakeEvent ==>> '+eventoGetEverybodyMakeEvent);
    }





System.debug(' returnList ==> '+returnList);
    
 

    upsert returnList;
    return returnList;
    
}




checkEvents(idAccountsForEvents());