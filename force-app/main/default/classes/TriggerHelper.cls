public with sharing class TriggerHelper {

    //used for Order Ticket Insert to validate inputs
    public static void checkForDuplicates(list<Order_Ticket__c> triggerlist){
        List<Order_Ticket__C> Tickets = [SELECT id, Pizza__c, Cook__c FROM Order_Ticket__c];
        for (Order_Ticket__C curr : triggerlist){
            for (Order_Ticket__C tik : Tickets){
                if (tik.cook__c == curr.cook__c && tik.pizza__c == curr.pizza__c){
                    curr.addError('this is a duplicate ticket');
                }
            }
        }
    }
    //Sets cart total cost to 0 upon creation
    public static void setCostToZero(list<Shopping_Cart__c> triggerlist){
        for (shopping_cart__c cart : triggerlist){
            cart.Total_Cost__c = 0;
        }
    }
    
    // used to update the price based on the size and toppings of the pizza
    public static void updatePrice(list<pizza__c> triggerlist){
        for (pizza__c toAdjust : triggerlist){

            toAdjust.Price__c = 0.00;

            switch on toAdjust.size__c {
                when 'Small' {
                    toAdjust.price__c += 10;
                }
                when 'Medium' {
                    toAdjust.price__c += 14;
                }
                when 'Large' {
                    toAdjust.price__c += 16;
                }
                when 'Extra_Large' {
                    toAdjust.price__c += 18;
                }
            }
            if (!(toAdjust.toppings__c == null)){
                if (toAdjust.toppings__c.contains('Pepporoni')){
                    toAdjust.price__c += .50;
                }
                if (toAdjust.toppings__c.contains('Bacon')){
                    toAdjust.price__c += .50;
                }
                if (toAdjust.toppings__c.contains('Sausage')){
                    toAdjust.price__c += .50;
                }
                if (toAdjust.toppings__c.contains('Pineapple')){
                    toAdjust.price__c += .50;
                }
            }
            //Discounts based on record type (special offers)
            
            String recordType = toAdjust.RecordTypeID;
            if (recordType == 'meatLoverSpecial'){
                toAdjust.price__c *= .80;
            }
            
        }
    }

    //Updates the price total of a shopping cart on pizza creation or update
    public static void updateShoppingCart(list<pizza__c> triggerlist, map<ID, pizza__c> triggermap){
        Map<ID, Decimal> pricedifferences = new Map<ID, Decimal>();
        for (pizza__c toAdjust : triggerlist){
            if (Trigger.isInsert || Trigger.isUndelete){
                pricedifferences.put(toAdjust.shopping_cart__c, toAdjust.price__c);
            } else if (Trigger.isDelete){
                pricedifferences.put(toAdjust.shopping_cart__c, (toAdjust.price__c * -1));
            } else {
                if (toAdjust.price__c != triggermap.get(toAdjust.id).price__c){
                    pricedifferences.put(toAdjust.shopping_cart__c, toAdjust.price__c - triggermap.get(toAdjust.id).price__c);
                }
            }
        }
        List<shopping_cart__c> cartList = [SELECT id, total_cost__c FROM Shopping_cart__c];
        for (shopping_cart__c toAdjust: cartList){
            if (!(pricedifferences.get(toAdjust.id) == null)){
                toAdjust.Total_Cost__c += pricedifferences.get(toAdjust.id);
            }
        }
        Update cartList;
    }
}