# 🍽️ Meals on Wheels - Dynamic Food Truck Menu  

**Live Demo** 👉 [Click here to view the live site](https://d24fkbtkc6qiqc.cloudfront.net)  

Meals on Wheels is a dynamic, serverless food truck website powered entirely by **Terraform** and **AWS**. It fetches a daily-updated menu from a **Google Sheet**, transforms it into JSON via **Lambda**, and serves it through a blazing fast **CloudFront CDN**. All infrastructure is built as code. 

---

## 🚀 Features  
✅ Fully static site hosted on **S3** and delivered via **CloudFront**
🛠 Infrastructure provisioned using **Terraform**
🧠 Menu data synced from **Google Sheets** to **menu.json** in S3
🐍 Backend logic via **AWS Lambda** (Python)
🔐 API Gateway integrated with Lambda (secured optionally)
🌑 Clean, dark-mode responsive UI 

---

## 🧱 Tech Stack  

| Layer           | Tech Stack                               |
|------------------|-----------------------------------------|
| Frontend         | HTML, CSS, JavaScript (vanilla)         |
| Backend          | AWS Lambda (Python 3.12)                |
| Infra as Code    | Terraform                               |
| Hosting          | AWS S3 + CloudFront                     |
| API Gateway      | HTTP API (via API Gateway)              |
| Data Source      | Google Sheets                           |


--- 


## 📂 Project Structure  

```bash
Terraform_p1/
├── images/
│   └── logo.png
├── lambda_src/
│   ├── handler.py
│   └── lambda.zip
├── error.html
├── index.html
├── main.tf
├── outputs.tf
├── variables.tf
├── .gitignore
├── .terraform.lock.hcl
└── README.md
```

--- 

## 🛠 Architecture

![Meals-on-wheels-architecture](https://github.com/user-attachments/assets/667c319a-f635-4047-a311-9136009f912f)

---


## 🔐 Secrets & Security
- Secrets like AWS credentials are never committed. They’re stored in `terraform.tfvars` (which is `.gitignore`d).
- The API Gateway can be locked with IAM or API keys if required.
- GitHub push protection is enabled for extra security.

--- 


## 🧪 How to Run Locally  

> **Note:** This is a cloud-native app and doesn't need a local dev server. But if you'd like to replicate:

1. Clone this repo      `git clone https://github.com/megh18497new/meals-on-wheels.git`
2. Set up your `terraform.tfvars` with your AWS keys:    ```hcl    aws_access_key = "your-access-key"    aws_secret_key = "your-secret-key"    aws_region     = "ap-south-1"    bucket_name    = "your-s3-bucket-name"    ```
3. Initialize Terraform      `terraform init`
4. Apply Infrastructure      `terraform apply`
5. Visit the output URL from `terraform apply`!
   
--- 

## 📸 Screenshot  

<img width="1436" alt="image" src="https://github.com/user-attachments/assets/78bde52c-7b0e-4780-b55c-972d9bbce175" />

--- 


## ✍️ Author  **Meghansh Khanna**  
Cloud Enthusiast | Network Automation Learner | Serverless Explorer   
[LinkedIn](https://www.linkedin.com/in/meghansh-khanna-6240501b0/) • [GitHub](https://github.com/megh18497new)  

---
