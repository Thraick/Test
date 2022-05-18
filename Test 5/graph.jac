// main node
node state {
    has name;
    has message;
    has prompts;

    can speak with entry {
        std.out(message);
    }
}

// appointment and general question answer
node ansstate:state{
    can speak with entry {
        std.out(message);
        visitor.skipinput = true;
    }    
}

// service node
node aboutstate {
    has name;
    has message;
    has prompts = ["yes", "no"];
    has prices = {'Spa':500, 'Manicures':600,'Haircuts':900,'Wedding Makeup':1000,'Eyebrows':300,'Facial Treatments':1200,'Pedicures':800,'Hair Steaming':200};
    has itemss= {};
    has total = 0;

    can speak with entry {
        if (!visitor.itemRequested): std.out(name+" is currently $" + prices[name].str + ". Would you like to proceed?");
        else{
            std.out(name+" is currently $" + prices[name].str + ". And you also have these items:\n");
 
            total = total + prices[name];


            for i=0 to i<(visitor.itemRequested.dict::items).length by i += 1 {
                total = total + visitor.itemRequested.dict::values[i];
                std.out(visitor.itemRequested.dict::keys[i].str + " is $" + visitor.itemRequested.dict::values[i].str);
            }
            std.out("Your total will be $" + total.str + ". Would you like to proceed?");
        }
        visitor.itemname = name.str;
        visitor.itemvalue = prices[name];
        
    }

}
// end of conversation
node closing_state {

    can speak with entry {
        std.out("Thank You for chosing us. Have a Greatday!");
        visitor.startdisengage = true; // this is used to disengage since it's not working in walker.

    }
} 
// create appointment
node appointdate {
    has data_input;

    can speak with entry {
        std.out("Please create your appointment.");
    }
}


edge transition {
    has intent;
}

graph main_graph {
    has anchor main_root;

    spawn{

        main_root = spawn node::state(
                                name = "Greeting",
                                message = "Welcome! What would you like to do?",
                                prompts = ["general business", "service", "appointment","office hours", "phone number", "email address","promotions","manicures","haircuts","wedding makeup","eyebrows","facial treatments","spa","pedicures","hair steaming","cancel", "reschedule", "refund", "feedback"]
        );

        remain_root = spawn node::state(
                                name = "Re Greeting",
                                message = "what else can I help you with?",
                                prompts = ["general business", "service", "appointment","office hours", "phone number", "email address","promotions","manicures","haircuts","wedding makeup","eyebrows","facial treatments","spa","pedicures","hair steaming","cancel", "reschedule", "refund", "feedback"]

        );

        other_question = spawn node::state(
                                name = "Other Question",
                                message="Is there anything else that I can help you with?",
                                prompts=["yes","no","general business", "service", "appointment","office hours", "phone number", "email address","promotions","manicures","haircuts","wedding makeup","eyebrows","facial treatments","spa","pedicures","hair steaming","cancel", "reschedule", "refund", "feedback"]
        );

        closing_state = spawn main_root -[transition(intent="closing")]-> node::closing_state;


        // General Business Queries //
        general_business_node = spawn main_root -[transition(intent="general business")]-> node::state(
                                name = "General Business Querries",
                                message = "How can I help you?",
                                prompts = ["back", "office hour", "phone number", "email address","promotions"]
        );

        general_business_node -[transition(intent="back")]->main_root;
        
        office_hours = spawn general_business_node -[transition(intent="office hours")]->
            node::ansstate(name="Office Hours", message="We usuall open between 10AM to 5PM during the week.");
        payment_method = spawn general_business_node -[transition(intent="payment method")]->
            node::ansstate(name="Payment Method", message="We only accept credit cards. [Red Card, Blue Card, Green Card");
        phone_number = spawn general_business_node -[transition(intent="phone number")]->
            node::ansstate(name="Phone Number", message="Our phone numbers are 592 633 3332 and 592 743 2322");
        email_address = spawn general_business_node -[transition(intent="email address")]->
            node::ansstate(name="Email Address", message="Our email is admin@min.co");
        promotions = spawn general_business_node -[transition(intent="promotions")]->
            node::ansstate(name="Promotions", message="We have a promotions for customer who have been with us for more than 2 years.");        

        office_hours -[transition(intent="back")]->general_business_node;
        payment_method -[transition(intent="back")]->general_business_node;
        phone_number -[transition(intent="back")]->general_business_node;
        email_address -[transition(intent="back")]->general_business_node;
        promotions -[transition(intent="back")]->general_business_node;



        // Service Related Queries //
        service_node = spawn main_root -[transition(intent="service")]-> node::state(
                                name = "Service",
                                message ="Which service would you like to request?",
                                prompts=["back","manicures","haircuts","wedding makeup","eyebrows","facial treatments","spa","pedicures","hair steaming"]
        );

        service_node -[transition(intent="back")]->main_root;

        manicures = spawn service_node -[transition(intent="manicures")]->
            node::aboutstate(name="Manicures");
        haircuts = spawn service_node -[transition(intent="haircuts")]->
            node::aboutstate(name="Haircuts");
        wedding_makeup = spawn service_node -[transition(intent="wedding makeup")]->
            node::aboutstate(name="Wedding Makeup");
        eyebrows = spawn service_node -[transition(intent="eyebrows")]->
            node::aboutstate(name="Eyebrows");
        facial_treatments = spawn service_node -[transition(intent="facial treatments")]->
            node::aboutstate(name="Facial Treatments");
        spa = spawn service_node -[transition(intent="spa")]->
            node::aboutstate(name="Spa");
        pedicures = spawn service_node -[transition(intent="pedicures")]->
            node::aboutstate(name="Pedicures");
        hair_steaming = spawn service_node -[transition(intent="hair steaming")]->
            node::aboutstate(name="Hair Steaming");

        manicures -[transition(intent="back")]->service_node;
        haircuts -[transition(intent="back")]->service_node;
        wedding_makeup -[transition(intent="back")]->service_node;
        eyebrows -[transition(intent="back")]->service_node;
        facial_treatments -[transition(intent="back")]->service_node;
        spa -[transition(intent="back")]->service_node;
        pedicures -[transition(intent="back")]->service_node;
        hair_steaming -[transition(intent="back")]->service_node;



        // Appointment Related Question //
        appt_node = spawn main_root -[transition(intent="appointment")]-> node::state(
                                name = "Appointment",
                                message = "How can I help you with your appointment?",
                                prompts =["back","cancel", "reschedule", "refund", "feedback"]
        );

        appt_node -[transition(intent="back")]->main_root;

        creat_apointment = spawn appt_node -[transition(intent="create appointment")]->
            node::appointdate;
        cancel = spawn appt_node -[transition(intent="cancel")]->
            node::ansstate(name="Cancel Appointment", message="Call us to cancel your appointment.");
        reschedule = spawn appt_node -[transition(intent="reschedule")]->
            node::ansstate(name="Reschedule Appointment", message="Call us to your appointment will be rescheduled.");
        refund = spawn appt_node -[transition(intent="refund")]->
            node::ansstate(name="Refund", message="Your refund will be send to your email. Please call us for more");
        feedback = spawn appt_node -[transition(intent="feedback")]->
            node::ansstate(name="Feedback", message="Please send your feedback by email.");

        cancel -[transition(intent="back")]->appt_node;
        reschedule -[transition(intent="back")]->appt_node;
        refund -[transition(intent="back")]->appt_node;
        feedback -[transition(intent="back")]->appt_node;


        cancel -[transition(intent="no")]->other_question;
        reschedule -[transition(intent="no")]->other_question;
        refund -[transition(intent="no")]->other_question;
        feedback -[transition(intent="no")]->other_question;


        // main root

        main_root -[transition(intent="office hours")]->office_hours;
        main_root -[transition(intent="payment method")]->payment_method;
        main_root -[transition(intent="phone number")]->phone_number;
        main_root -[transition(intent="email address")]->email_address;
        main_root -[transition(intent="promotions")]->promotions;

        main_root -[transition(intent="manicures")]->manicures;
        main_root -[transition(intent="haircuts")]->haircuts;
        main_root -[transition(intent="wedding makeup")]->wedding_makeup;
        main_root -[transition(intent="eyebrows")]->eyebrows;
        main_root -[transition(intent="facial treatments")]->facial_treatments;
        main_root -[transition(intent="spa")]->spa;
        main_root -[transition(intent="pedicures")]->pedicures;
        main_root -[transition(intent="hair steaming")]->hair_steaming;

        main_root -[transition(intent="cancel")]->cancel;
        main_root -[transition(intent="reschedule")]->reschedule;
        main_root -[transition(intent="refund")]->refund;
        main_root -[transition(intent="feedback")]->feedback;

        
        // remain root to ask other question
        remain_root -[transition(intent="general business")]-> general_business_node;
        remain_root -[transition(intent="service")]-> service_node;
        remain_root -[transition(intent="appointment")]-> appt_node;

        remain_root -[transition(intent="office hours")]->office_hours;
        remain_root -[transition(intent="payment method")]->payment_method;
        remain_root -[transition(intent="phone number")]->phone_number;
        remain_root -[transition(intent="email address")]->email_address;
        remain_root -[transition(intent="promotions")]->promotions;

        remain_root -[transition(intent="manicures")]->manicures;
        remain_root -[transition(intent="haircuts")]->haircuts;
        remain_root -[transition(intent="wedding makeup")]->wedding_makeup;
        remain_root -[transition(intent="eyebrows")]->eyebrows;
        remain_root -[transition(intent="facial treatments")]->facial_treatments;
        remain_root -[transition(intent="spa")]->spa;
        remain_root -[transition(intent="pedicures")]->pedicures;
        remain_root -[transition(intent="hair steaming")]->hair_steaming;

        remain_root -[transition(intent="cancel")]->cancel;
        remain_root -[transition(intent="reschedule")]->reschedule;
        remain_root -[transition(intent="refund")]->refund;
        remain_root -[transition(intent="feedback")]->feedback;

        // other question node to question
        other_question -[transition(intent="general business")]-> general_business_node;
        other_question -[transition(intent="service")]-> service_node;
        other_question -[transition(intent="appointment")]-> appt_node;

        other_question -[transition(intent="office hours")]->office_hours;
        other_question -[transition(intent="payment method")]->payment_method;
        other_question -[transition(intent="phone number")]->phone_number;
        other_question -[transition(intent="email address")]->email_address;
        other_question -[transition(intent="promotions")]->promotions;

        other_question -[transition(intent="manicures")]->manicures;
        other_question -[transition(intent="haircuts")]->haircuts;
        other_question -[transition(intent="wedding makeup")]->wedding_makeup;
        other_question -[transition(intent="eyebrows")]->eyebrows;
        other_question -[transition(intent="facial treatments")]->facial_treatments;
        other_question -[transition(intent="spa")]->spa;
        other_question -[transition(intent="pedicures")]->pedicures;
        other_question -[transition(intent="hair steaming")]->hair_steaming;

        other_question -[transition(intent="cancel")]->cancel;
        other_question -[transition(intent="reschedule")]->reschedule;
        other_question -[transition(intent="refund")]->refund;
        other_question -[transition(intent="feedback")]->feedback;


        // Create appointment for service

        manicures -[transition(intent="yes")]->creat_apointment;
        haircuts -[transition(intent="yes")]->creat_apointment;
        wedding_makeup -[transition(intent="yes")]->creat_apointment;
        eyebrows -[transition(intent="yes")]->creat_apointment;
        facial_treatments -[transition(intent="yes")]->creat_apointment;
        spa -[transition(intent="yes")]->creat_apointment;
        pedicures -[transition(intent="yes")]->creat_apointment;
        hair_steaming -[transition(intent="yes")]->creat_apointment;


        // closing and other question
        creat_apointment -[transition(intent="question")]->other_question;
        other_question -[transition(intent="yes")]->remain_root;
        other_question -[transition(intent="no")]->closing_state;

        // general other question
        office_hours -[transition(intent="question")]->other_question;
        payment_method -[transition(intent="question")]->other_question;
        phone_number -[transition(intent="question")]->other_question;
        email_address -[transition(intent="question")]->other_question;
        promotions -[transition(intent="question")]->other_question;

        // Service other question
        manicures -[transition(intent="no")]->other_question;
        haircuts -[transition(intent="no")]->other_question;
        wedding_makeup -[transition(intent="no")]->other_question;
        eyebrows -[transition(intent="no")]->other_question;
        facial_treatments -[transition(intent="no")]->other_question;
        spa -[transition(intent="no")]->other_question;
        pedicures -[transition(intent="no")]->other_question;
        hair_steaming -[transition(intent="no")]->other_question;

        // Appointment other question
        cancel -[transition(intent="question")]->other_question;
        reschedule -[transition(intent="question")]->other_question;
        refund -[transition(intent="question")]->other_question;
        feedback -[transition(intent="question")]->other_question;



    }
}
