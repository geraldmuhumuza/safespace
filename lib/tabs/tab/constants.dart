

final List<Map<String, String>> counsellors = [
  {
    "title": "Dr. John Doe",
    "subtitle": "For support and consultation"
   },
  {
    "title": "Dr. Sarah Williams",
    "subtitle": "Specialist in trauma counselling",
  },
  {
    "title": "Mr. Michael Lee",
    "subtitle": "Emotional and mental wellness guide",
  },
];
final List<Map<String, String>> motivations = [
  {
    "title": "You Are Not Alone",
    "subtitle":
        "Remember, you are surrounded by people who care about you, even when it doesn't feel that way",
  },
  {
    "title": "Healing Takes Time",
    "subtitle":
        "Healing isn't linear. Some days will be better than others, and that's perfectly okay.",
  },
  {
    "title": "Your Strength",
    "subtitle":
        "You've survived 100% of your worst days. That's an incredible track record.",
  },
  {
    "title": "Speaking Up",
    "subtitle":
        "Your voice matters. Speaking your truth is an act of courage and self love",
  },
];
final List<String> messages = [
  "Stay Safe",
  "You Are Not Alone",
  "We Are Here to Support You",
  "Your Mental Health Matters",
  "Your voice matters",
  "Healing isn't linear",
];
String generateReply(String userMessage) {
  userMessage = userMessage.toLowerCase();

  if (userMessage.contains("sad") || userMessage.contains("hurt")) {
    return "I'm really sorry you're feeling this way. You are not alone. Would you like to talk more about what’s hurting you?";
  }

  if (userMessage.contains("hello") || userMessage.contains("hi")) {
    return "Hi there. I'm here with you. What’s on your mind?";
  }

  if (userMessage.contains("help")) {
    return "I hear you. I’m here to support you. Can you tell me the kind of help you need right now?";
  }

  if (userMessage.contains("scared")) {
    return "It’s okay to feel scared. You're safe here. Do you want to talk about what’s making you feel this way?";
  }

  return "I understand. Please feel free to share more. I'm here to listen and support you.";
}

final Map<String, dynamic> userData = {
  "__path__": "Users/Users",
  "userid": 1,
  "Username": "gerald",
  "Date_creation": {
    "__type__": "Timestamp",
    "value": "2025-12-12T18:02:02.329Z",
  },
};
final List<String> images = [
    'assets/slide1.jpg',
    'assets/slide2.jpg',
    'assets/slide3.jpeg',
  ];


//SYSTEM PROMPT
final String prompt2 = "Refining Output ConstraintsI'm now zeroing in on the output constraints. My focus is on ensuring the response is concise, hitting the key points directly within a strict three-line limit. This involves prioritizing information for maximum impact and precision in a trauma-informed context.Defining The StructureI've got the structure defined, and now I'm attempting to nail down the precise wording. It's tough trying to get all the elements – greeting, validation, presence, and safety – into three lines. I'm focusing on simplicity and precision to best fit the context of sexual assault support. The current draft tries to encompass all the instructions in a concise format.Evaluating Revised OptionsI've revised the three-line draft, focusing on refining each sentence's core message. I am now trying to balance directness with empathy, making sure the key elements of greeting, validation, supportive presence, and safety guidance are conveyed effectively. I am concentrating on the most critical information in a gender-neutral way.Collapse to hide model thoughts";
final String prompt="You are a trauma-informed support assistant designed exclusively to help survivors of rape or sexual assault. You must operate with empathy, safety, and strict non-judgment at all times.Scope & RestrictionsYou may only respond to topics related to rape or sexual assault survivor support.If a user asks about anything outside this scope, gently redirect back to support or state that you can only help with sexual assault–related support.Do not provide legal strategy, investigative guidance, or graphic sexual content.Tone & LanguageAlways be polite, calm, apologetic when appropriate, and deeply sympathetic.Use gender-neutral language at all times. Never assume gender, identity, or sexuality.Be capable of gently acknowledging coping humor without encouraging it or minimizing trauma.Never interrogate, doubt, or challenge the user’s experience.Non-Blame & Non-Condemnation (Critical Rule).Never condemn the user or imply responsibility.Never suggest the assault occurred because of behavior, choices, clothing, substance use, trust, location, or circumstances.Explicitly affirm when appropriate:“What happened was not your fault.”“Nothing you did caused this.”Responsibility must always be framed as belonging only to the person who caused harm.Conversation Structure (Required for Every Response)Greeting & AvailabilityBegin every response with a warm greeting.Clearly state that you are present, available, and ready to listen.Validation & EmpathyAcknowledge the survivor’s feelings.Normalize emotional responses without minimizing pain.Reassure the user they are not alone.Supportive PresenceOffer comfort, grounding language, and reassurance.Do not pressure the user to share details or take actions.Safety Guidance (Must Appear at the End of Every Response)Gently encourage contacting emergency services.Gently encourage visiting a hospital or medical center for care and support.Phrase this as supportive advice, not a command, and respect the survivor’s autonomy.Prohibited BehaviorsNo victim-blaming, moral judgment, or “why” questions.No minimizing language (e.g., “at least,” “it could be worse”).No advice that prioritizes evidence over the survivor’s well-being.No opinions about punishment or perpetrators.Core Message to MaintainThe survivor is believed.The survivor is not at fault.The survivor deserves care, safety, and compassion.You are here to listen.";