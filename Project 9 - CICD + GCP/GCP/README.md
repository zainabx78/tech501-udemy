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


## Google Agentspace

### Deploy a Google Agentspace app integrated with enterprise data sources (Google Drive, Cloud Storage, and Calendar).

Login to google cloud skills boost website - Google Agentspace intro section labs. Free tokens available for labs. Rigjt click on open google console when lab started and open link in new tab. (Opens google console).

1. **Prepare data for AgentSpace:**
   - In storage bucket- download all files in agentspace-drive folder.
   - In new browser- Go to google drive - sign in with the lab account. Create a new folder called 'Agentspace Drive Assets' and upload downloaded files to this new folder. 
   - Back in cloud, download contents of 'notebooklm-drive' folder for later.
   - Add event to google calender- just go to google calender with lab account and add event. 
2. **Configure Agentspace and NotebookLM**
   - In google cloud, search for Agentspace and click on it - `continue and activate API`
   - In settings, set identity provider for global as `google identity`.
   - Configure NotebookLM- under licenses tab, add subscription for agentspace. Select `NotebookLM Enterprise Free Trial` and add. 
   - Add users and enter lab email address and select the free trial and submit. 

![alt text](<Images/Screenshot 2025-07-22 144301.png>)

3. Create the Agentspace data stores
   - AI Applications Left hand side menu - data stores. Create data store. Sync all. Create.
   - Create data store for google calendar in the same method. 
   - Create data store for cloud storage - add link for cloud store subfolder in lab bucket.

![alt text](<Images/Screenshot 2025-07-22 145220.png>)

4. Deploy an Agentspace app
   - This will serve as the central user-facing hub where employees can search for information and interact with the AI assistant. 
   - AI Applications Left hand side menu - Apps. Create App.
   - Select all the datastores created when creating App and create. 
![alt text](<Images/Screenshot 2025-07-22 150213.png>)

5. Query Agentspace Assistant
   - AI applications - Apps - YourApp - preview. It should show Agentspace AI. 
   - Left hand side - integration - copy and paste url link in new browser. 
   - Can query the company data using this with relevent files and documents on the side. 

CICD OVERVIEW- 

1. DEV PUSHES CHANGE TO DEV BRANCH
2. PUSH TRIGGERS JENKINS THROUGH WEBHOOK TRIGGER.
3. JENKINS RUNS JOB 1 - MERGING THE BRANCHES (DEV TO MAIN).
4. AFTER JOB 1 IS COMPLETE, JENKINS AUTOMATICALLY RUNS JOB 2 ONLY IF JOB 1 IS SUCCESSFUL. 
5. JOB 2 = TESTING.
6. JOB 3 = PUSHING CHANGE ONTO THE ACTUAL WEBSITE. 

Credentials needed = jenkins needs github creds and jenkins needs ec2 creds that the website runs on. 


WITH KUBERNETES AND DOCKER:

1. DEV PUSHES CHANGE TO DEV BRANCH
2. JENKINS TRIGGERED- WEBHOOK
3. DOCKERHUB IMAGE UPDATED
4. NEW IMAGE DEPLOYED ON KUBERNETES

