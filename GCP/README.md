# GCP - AI 

Vertex AI is a powerful machine learning (ML) platform offered by Google Cloud Platform (GCP). It brings together all the tools needed to build, train, and deploy ML models at scale—whether you're using pre-built models, AutoML, or custom training code.

## Building AI Agents with Vertex AI Agent Builder

1. **Vertex AI Agent Builder** - activate API
   - Create a new app - conversational agent- create.
2. **Set up agent** - Build your own (name- Travel buddy). 
   - Create a playbook - save.
3. Test your agent - try chatting with agent. 
4. Add datastore for agent to have additional knowledge. 
   - Agent basics- tools - data store. 
   - Add data stores - create a data store. 
5. Link the data store to the agent. 
   - In tool config, add the new data store.
   - In playbook instructions, add the datastore in the tool area.
6. Test with the datastore - if it returns with alternative suggestions. 
7. Making AI Agent live - publish agent -. 
   - ask Gemini Code Assist to create a flask app and integrate section of code from agent. 



CICD OVERVIEW- 

1. DEV PUSHES CHANGE TO DEV BRANCH
2. PUSH TRIGGERS JENKINS THROUGH WEBHOOK TRIGGER.
3. JENKINS RUNS JOB 1 - MERGING THE BRANCHES (DEV TO MAIN).
4. AFTER JOB 1 IS COMPLETE, JENKINS AUTOMATICALLY RUNS JOB 2 ONLY IF JOB 1 IS SUCCESSFUL. 
5. JOB 2 = TESTING.
6. JOB 3 = PUSHING CHANGE ONTO THE ACTUAL WEBSITE. 

Credentials needed = jenkins needs github creds and jenkins needs ec2 creds that the website runs on. 


