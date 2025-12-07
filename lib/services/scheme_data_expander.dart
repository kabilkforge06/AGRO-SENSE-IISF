import 'dart:developer' as developer;
import '../models/government_scheme.dart';

/// Service to expand basic scheme data into detailed scheme information
class SchemeDataExpander {
  /// Get detailed scheme information by scheme ID
  /// Returns null if scheme not found
  static Map<String, dynamic>? getDetailedSchemeById(String schemeId) {
    final schemes = _getAllDetailedSchemes();
    try {
      return schemes.firstWhere((scheme) => scheme['id'] == schemeId);
    } catch (e) {
      return null;
    }
  }

  /// Get all detailed schemes as JSON
  static List<Map<String, dynamic>> _getAllDetailedSchemes() {
    return [
      // PM-KISAN - Pradhan Mantri Kisan Samman Nidhi
      {
        "id": "pm-kisan-002",
        "name": "Pradhan Mantri Kisan Samman Nidhi (PM-KISAN)",
        "description":
            "Income support scheme providing ₹6,000 annual direct cash transfer to eligible farmer families in three equal installments to supplement income for agricultural needs.",
        "category": "Financial Aid",
        "type": "Central",
        "states": ["All"],
        "districts": [[]],
        "eligibilityCriteria": {
          "requiresAadhar": true,
          "requiresBankAccount": true,
          "maxLandHolding": 999,
          "minLandHolding": 0,
          "farmerCategories": ["Small", "Marginal", "Large"],
          "applicableCrops": ["All"],
        },
        "subsidyPercentage": null,
        "maxSubsidyAmount": 6000,
        "minSubsidyAmount": 6000,
        "requiredDocuments": [
          "Aadhar Card",
          "Bank Account Details with IFSC",
          "Land Ownership Documents (7/12, 8A, Patta, etc.)",
          "Self Declaration Form",
          "Passport Size Photograph",
        ],
        "applicationSteps": [
          {
            "stepNumber": 1,
            "title": "Complete eKYC and Registration",
            "description":
                "Visit PM-KISAN portal or nearest CSC to register with your Aadhar number and complete eKYC verification through OTP or biometric authentication.",
            "requiredActions": [
              "Visit https://pmkisan.gov.in or nearest Common Service Center",
              "Click on 'Farmers Corner' > 'New Farmer Registration'",
              "Enter Aadhar number and mobile number",
              "Complete eKYC through OTP or biometric verification",
              "Fill farmer details, land records, and bank account information",
            ],
            "url": "https://pmkisan.gov.in",
          },
          {
            "stepNumber": 2,
            "title": "Submit Land Records and Bank Details",
            "description":
                "Upload land ownership documents and provide accurate bank account details with IFSC code for direct benefit transfer.",
            "requiredActions": [
              "Upload clear scanned copies of land records (7/12, 8A, Patta)",
              "Enter correct bank account number and IFSC code",
              "Ensure bank account is Aadhar-linked for DBT",
              "Submit self-declaration form acknowledging eligibility",
              "Save acknowledgment receipt with reference number",
            ],
            "url": "https://pmkisan.gov.in/RegistrationForm.aspx",
          },
          {
            "stepNumber": 3,
            "title": "Verification and Approval",
            "description":
                "Application will be verified by Patwari/Village Officer and State Agriculture Department. Track status online and receive installments directly in bank account.",
            "requiredActions": [
              "Wait for verification by local revenue officials (7-15 days)",
              "Track application status using Aadhar or mobile number",
              "Receive installments in February, June, and October",
              "Check beneficiary status at 'Know Your Status' section",
              "Contact helpline 155261 or PM-KISAN Kendra for queries",
            ],
            "url": "https://pmkisan.gov.in/BeneficiaryStatus.aspx",
          },
        ],
        "startDate": "2019-02-24T00:00:00Z",
        "expiryDate": null,
        "applicationUrl": "https://pmkisan.gov.in",
        "helplineNumber": "155261",
        "officialWebsite": "https://pmkisan.gov.in",
        "isActive": true,
        "benefitDetails": [
          "Direct cash transfer of ₹6,000 per year (₹2,000 per installment)",
          "Three equal installments in February, June, and October",
          "No need to visit government offices - fully online process",
          "Instant DBT to bank account within 7 days of approval",
        ],
        "departmentName":
            "Department of Agriculture and Farmers Welfare, Ministry of Agriculture",
        "source": "pmkisan.gov.in",
      },

      // PMFBY - Pradhan Mantri Fasal Bima Yojana
      {
        "id": "pmfby-001",
        "name": "Pradhan Mantri Fasal Bima Yojana (PMFBY)",
        "description":
            "Comprehensive crop insurance scheme providing financial support against crop loss/damage from natural calamities, pests, and diseases with minimal farmer premium.",
        "category": "Crop Insurance",
        "type": "Central",
        "states": ["All"],
        "districts": [[]],
        "eligibilityCriteria": {
          "requiresAadhar": true,
          "requiresBankAccount": true,
          "maxLandHolding": 999,
          "minLandHolding": 0,
          "farmerCategories": ["All"],
          "applicableCrops": ["All notified crops"],
        },
        "subsidyPercentage": 90,
        "maxSubsidyAmount": null,
        "minSubsidyAmount": null,
        "requiredDocuments": [
          "Aadhar Card",
          "Bank Account Details with IFSC",
          "Land Ownership Documents (7/12, 8A, etc.)",
          "Crop Sowing Certificate from Sarpanch/Patwari",
          "Land Survey Number and Khasra Details",
          "Loan Sanction Letter (if applicable)",
        ],
        "applicationSteps": [
          {
            "stepNumber": 1,
            "title": "Enroll During Sowing Season",
            "description":
                "Apply for crop insurance during the prescribed enrollment period (typically 7 days before sowing to cut-off date) through bank, CSC, insurance portal, or mobile app.",
            "requiredActions": [
              "Visit PMFBY portal, nearest bank branch, or CSC within cut-off date",
              "Select crop season (Kharif/Rabi) and notified crops",
              "Provide land details, area under cultivation, and crop sowing date",
              "Pay nominal premium (2% for Kharif, 1.5% for Rabi, 5% for horticulture)",
              "Loanee farmers get automatic enrollment through banks",
            ],
            "url": "https://pmfby.gov.in",
          },
          {
            "stepNumber": 2,
            "title": "Pay Premium and Submit Documents",
            "description":
                "Pay the farmer's share of premium (highly subsidized - government pays 90%+) and submit required documents for policy issuance.",
            "requiredActions": [
              "Pay premium through online payment, bank, or CSC",
              "Submit land records and crop sowing certificate",
              "Ensure Aadhar-linked bank account for claim settlement",
              "Receive policy document with sum insured details",
              "Note policy number and insurance company contact",
            ],
            "url": "https://pmfby.gov.in/farmerRegistration",
          },
          {
            "stepNumber": 3,
            "title": "Claim Settlement and Verification",
            "description":
                "In case of crop loss, inform authorities within 72 hours. Claims are settled based on Crop Cutting Experiments (CCE) and satellite data for localized losses.",
            "requiredActions": [
              "Report crop loss within 72 hours to insurance company, bank, or district agriculture office",
              "Provide loss details through toll-free number 14447 or mobile app",
              "Allow CCE survey and assessment by insurance officials",
              "Track claim status on PMFBY portal using policy/Aadhar number",
              "Receive claim amount directly in bank account (average 30-45 days)",
            ],
            "url": "https://pmfby.gov.in/claimStatus",
          },
        ],
        "startDate": "2016-01-13T00:00:00Z",
        "expiryDate": null,
        "applicationUrl": "https://pmfby.gov.in",
        "helplineNumber": "14447",
        "officialWebsite": "https://pmfby.gov.in",
        "isActive": true,
        "benefitDetails": [
          "Low premium rates: 2% for Kharif crops, 1.5% for Rabi crops, 5% for horticulture",
          "Government subsidizes 90%+ of actuarial premium cost",
          "Coverage for natural calamities, pests, diseases, and localized risks",
          "Quick claim settlement using technology (CCE + satellite data)",
        ],
        "departmentName":
            "Department of Agriculture and Farmers Welfare, Ministry of Agriculture",
        "source": "pmfby.gov.in",
      },

      // PMKSY - Pradhan Mantri Krishi Sinchayee Yojana
      {
        "id": "pmksy-001",
        "name": "Pradhan Mantri Krishi Sinchayee Yojana (PMKSY)",
        "description":
            "Irrigation subsidy scheme promoting micro-irrigation systems (drip/sprinkler) to enhance water use efficiency and ensure assured irrigation with 'More Crop Per Drop' approach.",
        "category": "Equipment Subsidy",
        "type": "Central",
        "states": ["All"],
        "districts": [[]],
        "eligibilityCriteria": {
          "requiresAadhar": true,
          "requiresBankAccount": true,
          "maxLandHolding": 999,
          "minLandHolding": 0.1,
          "farmerCategories": ["Small", "Marginal", "Large"],
          "applicableCrops": ["All"],
        },
        "subsidyPercentage": 55,
        "maxSubsidyAmount": 100000,
        "minSubsidyAmount": 5000,
        "requiredDocuments": [
          "Aadhar Card",
          "Bank Account Details with IFSC",
          "Land Ownership Documents (7/12, 8A, Patta)",
          "Water Availability Certificate",
          "Soil Test Report",
          "Quotation from Authorized Supplier/Dealer",
        ],
        "applicationSteps": [
          {
            "stepNumber": 1,
            "title": "Apply Through State Horticulture/Agriculture Department",
            "description":
                "Submit application with required documents to district horticulture/agriculture office or online portal for micro-irrigation system installation.",
            "requiredActions": [
              "Visit state agriculture department portal or district office",
              "Fill PMKSY application form with land and crop details",
              "Upload land records, soil test report, and water source proof",
              "Obtain quotation from authorized drip/sprinkler system supplier",
              "Submit application and receive acknowledgment number",
            ],
            "url": "https://pmksy.gov.in",
          },
          {
            "stepNumber": 2,
            "title": "Site Inspection and Technical Approval",
            "description":
                "Agriculture officials will conduct site inspection to verify land, water source, and suitability for micro-irrigation. Technical approval required before installation.",
            "requiredActions": [
              "Coordinate with department for site inspection",
              "Ensure water source availability (bore well, canal, pond)",
              "Get technical sanction from agricultural engineer",
              "Receive approval letter with subsidy amount details",
              "Pay farmer's share (45%) to approved dealer",
            ],
            "url": null,
          },
          {
            "stepNumber": 3,
            "title": "Installation and Subsidy Release",
            "description":
                "Install micro-irrigation system through authorized dealer/supplier. After successful installation and verification, subsidy amount (55%) will be released to your account.",
            "requiredActions": [
              "Get system installed by empaneled dealer within specified timeframe",
              "Ensure proper installation as per technical specifications",
              "Get post-installation inspection done by department officials",
              "Submit installation certificate and photos to department",
              "Receive 55% subsidy (up to ₹1 lakh) directly in bank account",
            ],
            "url": "https://pmksy.gov.in/MIS/Default.aspx",
          },
        ],
        "startDate": "2015-07-01T00:00:00Z",
        "expiryDate": null,
        "applicationUrl": "https://pmksy.gov.in",
        "helplineNumber": "1800-180-1551",
        "officialWebsite": "https://pmksy.gov.in",
        "isActive": true,
        "benefitDetails": [
          "55% subsidy on drip/sprinkler irrigation systems (up to ₹1 lakh per hectare)",
          "Additional 10% subsidy for SC/ST farmers in some states",
          "Water use efficiency increased by 40-60% with micro-irrigation",
          "20-40% increase in crop productivity with controlled irrigation",
        ],
        "departmentName":
            "Department of Agriculture and Farmers Welfare & Ministry of Jal Shakti",
        "source": "pmksy.gov.in",
      },

      // e-NAM - e-National Agriculture Market
      {
        "id": "e-nam-001",
        "name": "e-National Agriculture Market (e-NAM)",
        "description":
            "Pan-India electronic trading platform connecting APMC mandis to provide transparent price discovery, better market access, and reduced transaction costs for farmers selling agricultural produce.",
        "category": "Market Access",
        "type": "Central",
        "states": ["All"],
        "districts": [[]],
        "eligibilityCriteria": {
          "requiresAadhar": true,
          "requiresBankAccount": true,
          "maxLandHolding": 999,
          "minLandHolding": 0,
          "farmerCategories": ["All"],
          "applicableCrops": ["All agricultural produce"],
        },
        "subsidyPercentage": null,
        "maxSubsidyAmount": null,
        "minSubsidyAmount": null,
        "requiredDocuments": [
          "Aadhar Card",
          "Bank Account Details with IFSC",
          "Land Ownership Documents or Farmer Certificate",
          "APMC/Mandi Registration Card (if available)",
          "Mobile Number",
        ],
        "applicationSteps": [
          {
            "stepNumber": 1,
            "title": "Register on e-NAM Portal",
            "description":
                "Create farmer account on e-NAM portal by providing Aadhar, bank details, and completing KYC verification at registered APMC mandi.",
            "requiredActions": [
              "Visit https://enam.gov.in/web and click 'Registration'",
              "Fill farmer registration form with Aadhar and bank details",
              "Upload required documents (Aadhar, bank passbook, land records)",
              "Select nearest e-NAM integrated APMC mandi",
              "Visit selected mandi for physical verification and KYC completion",
            ],
            "url": "https://enam.gov.in/web/registration",
          },
          {
            "stepNumber": 2,
            "title": "KYC Verification at APMC Mandi",
            "description":
                "Complete KYC verification at e-NAM integrated APMC mandi with original documents. Receive unique e-NAM ID for online trading.",
            "requiredActions": [
              "Visit registered e-NAM mandi with original documents",
              "Complete biometric/Aadhar verification",
              "Get e-NAM trading card with unique ID",
              "Link bank account for payment settlement",
              "Receive login credentials for e-NAM mobile app/portal",
            ],
            "url": "https://enam.gov.in/web/find-mandi",
          },
          {
            "stepNumber": 3,
            "title": "Trade and Receive Payments",
            "description":
                "Bring agricultural produce to e-NAM mandi, get quality assessment, view online bids from buyers across India, and receive payment directly in bank account within 24-48 hours.",
            "requiredActions": [
              "Bring produce to e-NAM integrated APMC mandi",
              "Get quality testing and grading done at mandi",
              "View online bidding from buyers pan-India on portal/app",
              "Accept best price offer electronically",
              "Receive payment directly in bank account within 24-48 hours",
            ],
            "url": "https://enam.gov.in/web/mobile-app",
          },
        ],
        "startDate": "2016-04-14T00:00:00Z",
        "expiryDate": null,
        "applicationUrl": "https://enam.gov.in",
        "helplineNumber": "1800-270-0224",
        "officialWebsite": "https://enam.gov.in",
        "isActive": true,
        "benefitDetails": [
          "Access to pan-India market with 1,300+ integrated APMC mandis",
          "Transparent price discovery through online competitive bidding",
          "Reduced transaction costs and middlemen involvement",
          "Direct bank transfer of payment within 24-48 hours",
        ],
        "departmentName":
            "Department of Agriculture and Farmers Welfare, Ministry of Agriculture",
        "source": "enam.gov.in",
      },

      // RKVY - Rashtriya Krishi Vikas Yojana
      {
        "id": "rkvy-001",
        "name": "Rashtriya Krishi Vikas Yojana (RKVY-RAFTAAR)",
        "description":
            "State agriculture development scheme providing funding for innovative projects, infrastructure development, value chain creation, and technology adoption to accelerate agricultural growth.",
        "category": "Training",
        "type": "Central",
        "states": ["All"],
        "districts": [[]],
        "eligibilityCriteria": {
          "requiresAadhar": false,
          "requiresBankAccount": true,
          "maxLandHolding": 999,
          "minLandHolding": 0,
          "farmerCategories": ["All"],
          "applicableCrops": ["All"],
        },
        "subsidyPercentage": null,
        "maxSubsidyAmount": null,
        "minSubsidyAmount": null,
        "requiredDocuments": [
          "Project Proposal with Detailed Project Report (DPR)",
          "Land Details and Ownership Documents",
          "Registration Certificate (for FPOs/Cooperatives)",
          "Bank Account Details",
          "Quotations and Cost Estimates",
        ],
        "applicationSteps": [
          {
            "stepNumber": 1,
            "title": "Prepare and Submit Project Proposal",
            "description":
                "Prepare detailed project report (DPR) aligned with RKVY focus areas and submit to district/state agriculture department for evaluation.",
            "requiredActions": [
              "Identify project under RKVY components (infrastructure, value chain, innovation, etc.)",
              "Prepare detailed project report with cost estimates and timelines",
              "Submit proposal to District Level Approval Committee (DLAC)",
              "Ensure project aligns with State Agriculture Plan priorities",
              "Provide supporting documents and feasibility study",
            ],
            "url": "https://rkvy.nic.in",
          },
          {
            "stepNumber": 2,
            "title": "Project Evaluation and Approval",
            "description":
                "Project will be evaluated by State Level Sanctioning Committee (SLSC) based on feasibility, innovation, impact, and alignment with RKVY objectives.",
            "requiredActions": [
              "District committee evaluates and forwards to state level",
              "State Level Sanctioning Committee (SLSC) reviews proposal",
              "Technical committee assesses feasibility and cost estimates",
              "Approval based on innovation, scalability, and farmer impact",
              "Receive sanction letter with funding details and conditions",
            ],
            "url": null,
          },
          {
            "stepNumber": 3,
            "title": "Implementation and Fund Release",
            "description":
                "Implement approved project as per DPR and timelines. Funds released in installments based on progress monitoring and utilization certificates.",
            "requiredActions": [
              "Execute project as per approved DPR and technical specifications",
              "Submit progress reports and utilization certificates regularly",
              "Maintain proper accounts and documentation of expenses",
              "Allow monitoring and inspection by department officials",
              "Receive fund installments upon verification of milestones",
            ],
            "url": "https://rkvy.nic.in/Default.aspx",
          },
        ],
        "startDate": "2007-08-01T00:00:00Z",
        "expiryDate": null,
        "applicationUrl": "https://rkvy.nic.in",
        "helplineNumber": "011-23381011",
        "officialWebsite": "https://rkvy.nic.in",
        "isActive": true,
        "benefitDetails": [
          "Funding for innovative agriculture projects and infrastructure",
          "Support for farmer producer organizations (FPOs) and cooperatives",
          "Promotion of value addition, post-harvest management, and agri-enterprises",
          "Technology adoption and demonstration of best practices",
        ],
        "departmentName":
            "Department of Agriculture and Farmers Welfare, Ministry of Agriculture",
        "source": "rkvy.nic.in",
      },

      // NMSA - National Mission on Sustainable Agriculture
      {
        "id": "nmsa-001",
        "name": "National Mission on Sustainable Agriculture (NMSA)",
        "description":
            "Climate-resilient agriculture mission promoting sustainable practices, soil health management, integrated farming, and water conservation to enhance productivity and farmer income.",
        "category": "Training",
        "type": "Central",
        "states": ["All"],
        "districts": [[]],
        "eligibilityCriteria": {
          "requiresAadhar": true,
          "requiresBankAccount": true,
          "maxLandHolding": 999,
          "minLandHolding": 0,
          "farmerCategories": ["All"],
          "applicableCrops": ["All"],
        },
        "subsidyPercentage": 50,
        "maxSubsidyAmount": 50000,
        "minSubsidyAmount": 1000,
        "requiredDocuments": [
          "Aadhar Card",
          "Bank Account Details with IFSC",
          "Land Ownership Documents (7/12, Patta, etc.)",
          "Soil Health Card",
          "Training Participation Certificate (if applicable)",
        ],
        "applicationSteps": [
          {
            "stepNumber": 1,
            "title": "Enroll in NMSA Programs",
            "description":
                "Register for NMSA schemes like Soil Health Management, Rainfed Area Development, or Climate Change adaptation through state agriculture department.",
            "requiredActions": [
              "Visit district agriculture office or state portal",
              "Select NMSA component (soil health, rainfed, climate adaptation, etc.)",
              "Fill application form with land and crop details",
              "Get Soil Health Card from nearest testing center",
              "Attend orientation session on sustainable agriculture practices",
            ],
            "url": "https://nmsa.dac.gov.in",
          },
          {
            "stepNumber": 2,
            "title": "Training and Technical Support",
            "description":
                "Participate in training programs on sustainable agriculture, soil health management, organic farming, and climate-resilient practices organized by agriculture department.",
            "requiredActions": [
              "Attend mandatory training programs at Krishi Vigyan Kendra (KVK)",
              "Learn soil testing, organic inputs, integrated pest management",
              "Get guidance on crop diversification and climate-smart agriculture",
              "Receive technical handholding from agriculture extension officers",
              "Obtain training certificate for subsidy eligibility",
            ],
            "url": null,
          },
          {
            "stepNumber": 3,
            "title": "Implementation and Subsidy Release",
            "description":
                "Implement sustainable agriculture practices on your land. Get 50% subsidy on inputs like organic fertilizers, bio-pesticides, water conservation structures, and farm equipment.",
            "requiredActions": [
              "Adopt recommended sustainable agriculture practices",
              "Purchase inputs from approved suppliers with valid bills",
              "Submit implementation report with photos and receipts",
              "Get field verification done by agriculture officer",
              "Receive 50% subsidy (up to ₹50,000) in bank account",
            ],
            "url": "https://nmsa.dac.gov.in/Default.aspx",
          },
        ],
        "startDate": "2014-12-01T00:00:00Z",
        "expiryDate": null,
        "applicationUrl": "https://nmsa.dac.gov.in",
        "helplineNumber": "011-23384646",
        "officialWebsite": "https://nmsa.dac.gov.in",
        "isActive": true,
        "benefitDetails": [
          "50% subsidy on sustainable agriculture inputs and equipment (up to ₹50,000)",
          "Free soil health testing and customized fertilizer recommendations",
          "Training on climate-resilient practices and integrated farming systems",
          "Support for water conservation, organic farming, and soil health improvement",
        ],
        "departmentName":
            "Department of Agriculture and Farmers Welfare, Ministry of Agriculture",
        "source": "nmsa.dac.gov.in",
      },

      // KCC - Kisan Credit Card
      {
        "id": "kcc-001",
        "name": "Kisan Credit Card Scheme (KCC)",
        "description":
            "Hassle-free credit facility for farmers to meet short-term cultivation expenses, purchase inputs, and allied activities with low interest rates (4% effective with interest subvention).",
        "category": "Financial Aid",
        "type": "Central",
        "states": ["All"],
        "districts": [[]],
        "eligibilityCriteria": {
          "requiresAadhar": true,
          "requiresBankAccount": true,
          "maxLandHolding": 999,
          "minLandHolding": 0,
          "farmerCategories": ["All"],
          "applicableCrops": ["All"],
        },
        "subsidyPercentage": null,
        "maxSubsidyAmount": 300000,
        "minSubsidyAmount": 50000,
        "requiredDocuments": [
          "Aadhar Card",
          "Bank Account Details with IFSC",
          "Land Ownership Documents (7/12, 8A, Patta, Passbook)",
          "Crop Pattern Details and Cultivation Area",
          "Passport Size Photographs",
          "PM-KISAN Registration (if applicable)",
        ],
        "applicationSteps": [
          {
            "stepNumber": 1,
            "title": "Visit Bank Branch or Apply Online",
            "description":
                "Apply for Kisan Credit Card at any commercial bank, cooperative bank, or regional rural bank. PM-KISAN beneficiaries can apply online through PM-KISAN portal.",
            "requiredActions": [
              "Visit nearest bank branch with KCC facility or apply online",
              "Fill KCC application form with land and crop details",
              "PM-KISAN beneficiaries: Apply through https://pmkisan.gov.in",
              "Submit required documents (Aadhar, land records, bank details)",
              "Provide details of cultivation area and cropping pattern",
            ],
            "url": "https://pmkisan.gov.in/RegistrationForm.aspx",
          },
          {
            "stepNumber": 2,
            "title": "Credit Assessment and Verification",
            "description":
                "Bank will assess credit limit based on land holding, cropping pattern, and Scale of Finance. Land documents and KYC verification will be completed.",
            "requiredActions": [
              "Bank calculates credit limit using formula: Land area × Crop cost + allied activities",
              "Submit land records for verification of ownership/tenancy",
              "Complete Aadhar-based KYC and biometric authentication",
              "Provide crop insurance consent for PMFBY coverage",
              "Credit approval typically within 7-15 working days",
            ],
            "url": null,
          },
          {
            "stepNumber": 3,
            "title": "Card Issuance and Credit Utilization",
            "description":
                "Receive KCC (debit/RuPay card) with approved credit limit. Withdraw cash or purchase inputs from dealers. Repay after harvest to avail 4% interest rate with prompt repayment incentive.",
            "requiredActions": [
              "Collect KCC card with approved credit limit and PIN",
              "Use card for cash withdrawal at ATMs or input purchases",
              "Credit limit valid for 5 years with annual review",
              "Repay within one year to get 3% interest subvention (4% effective)",
              "Get additional 3% incentive on prompt repayment (1% effective interest)",
            ],
            "url": "https://www.nabard.org/content1.aspx?id=571",
          },
        ],
        "startDate": "1998-08-12T00:00:00Z",
        "expiryDate": null,
        "applicationUrl": "https://pmkisan.gov.in or bank branches",
        "helplineNumber": "1800-180-1551",
        "officialWebsite": "https://www.nabard.org",
        "isActive": true,
        "benefitDetails": [
          "Timely credit access up to ₹3 lakh without collateral",
          "Highly subsidized interest rates: 4% effective (with interest subvention)",
          "Additional 3% prompt repayment incentive (effective 1% interest)",
          "Automatic PMFBY crop insurance coverage with affordable premium",
        ],
        "departmentName":
            "NABARD in coordination with Department of Financial Services",
        "source": "nabard.org",
      },

      // PMFME - PM Formalisation of Micro Food Processing Enterprises
      {
        "id": "pmfme-001",
        "name": "PM Formalisation of Micro Food Processing Enterprises (PMFME)",
        "description":
            "Scheme to formalize and upgrade micro food processing enterprises through credit-linked subsidies, training, and common infrastructure for value addition and brand creation.",
        "category": "Financial Aid",
        "type": "Central",
        "states": ["All"],
        "districts": [[]],
        "eligibilityCriteria": {
          "requiresAadhar": true,
          "requiresBankAccount": true,
          "maxLandHolding": 999,
          "minLandHolding": 0,
          "farmerCategories": ["All"],
          "applicableCrops": ["All food crops"],
        },
        "subsidyPercentage": 35,
        "maxSubsidyAmount": 10000000,
        "minSubsidyAmount": 40000,
        "requiredDocuments": [
          "Aadhar Card",
          "Bank Account Details with IFSC",
          "Business Plan and Project Report",
          "FSSAI License or Application",
          "Land/Building Documents for Enterprise",
          "Udyam Registration (for units > ₹1 Cr investment)",
        ],
        "applicationSteps": [
          {
            "stepNumber": 1,
            "title": "Register on PMFME Portal",
            "description":
                "Register your micro food processing enterprise on PMFME portal and select appropriate support component (individual unit, FPO, common infrastructure).",
            "requiredActions": [
              "Visit https://pmfme.mofpi.gov.in and click 'Registration'",
              "Fill enterprise details: food category, processing activity, investment",
              "Upload Aadhar, bank details, and business plan",
              "Select support type: Credit-linked subsidy or Common Infrastructure",
              "Submit online application and save acknowledgment",
            ],
            "url": "https://pmfme.mofpi.gov.in",
          },
          {
            "stepNumber": 2,
            "title": "Training and Business Plan Approval",
            "description":
                "Attend mandatory entrepreneurship training organized by state implementing agency. Get business plan evaluated and approved for credit-linked subsidy.",
            "requiredActions": [
              "Complete 5-7 days training on food processing, FSSAI norms, marketing",
              "Prepare/refine business plan with cost estimates and fund requirement",
              "Submit business plan to District Level Committee (DLC)",
              "Get technical evaluation done by food processing experts",
              "Receive approval letter with eligible loan and subsidy amount",
            ],
            "url": null,
          },
          {
            "stepNumber": 3,
            "title": "Avail Loan and Receive Subsidy",
            "description":
                "Apply for bank loan as per approved project cost. After loan sanction, receive 35% credit-linked subsidy (up to ₹10 lakh) directly in bank account for enterprise establishment.",
            "requiredActions": [
              "Apply for bank loan (65% of project cost) with DLC approval",
              "Set up/upgrade food processing unit as per business plan",
              "Get FSSAI license and complete registrations",
              "Submit utilization certificate and unit photos to implementing agency",
              "Receive 35% subsidy (up to ₹10 lakh) in bank account",
            ],
            "url": "https://pmfme.mofpi.gov.in/pmfme/#/login",
          },
        ],
        "startDate": "2020-06-29T00:00:00Z",
        "expiryDate": "2025-03-31T23:59:59Z",
        "applicationUrl": "https://pmfme.mofpi.gov.in",
        "helplineNumber": "0120-2494380",
        "officialWebsite": "https://pmfme.mofpi.gov.in",
        "isActive": true,
        "benefitDetails": [
          "35% credit-linked subsidy on bank loan (up to ₹10 lakh per unit)",
          "Free entrepreneurship training on food processing and business management",
          "Support for FSSAI licensing, branding, and packaging design",
          "Access to common infrastructure, labs, and marketing support",
        ],
        "departmentName": "Ministry of Food Processing Industries",
        "source": "pmfme.mofpi.gov.in",
      },

      // PKVY - Paramparagat Krishi Vikas Yojana
      {
        "id": "pkvy-001",
        "name": "Paramparagat Krishi Vikas Yojana (PKVY)",
        "description":
            "Organic farming promotion scheme supporting cluster-based PGS certification, traditional practices, and market linkages with ₹50,000 per hectare assistance for 3 years.",
        "category": "Training",
        "type": "Central",
        "states": ["All"],
        "districts": [[]],
        "eligibilityCriteria": {
          "requiresAadhar": true,
          "requiresBankAccount": true,
          "maxLandHolding": 999,
          "minLandHolding": 0.1,
          "farmerCategories": ["All"],
          "applicableCrops": ["Organic crops"],
        },
        "subsidyPercentage": 50,
        "maxSubsidyAmount": 50000,
        "minSubsidyAmount": 20000,
        "requiredDocuments": [
          "Aadhar Card",
          "Bank Account Details with IFSC",
          "Land Ownership Documents (7/12, Patta, etc.)",
          "Cluster Formation Certificate (20-50 farmers)",
          "Consent Letter from All Cluster Farmers",
          "Soil Test Report",
        ],
        "applicationSteps": [
          {
            "stepNumber": 1,
            "title": "Form Organic Farming Cluster",
            "description":
                "Form a cluster of minimum 20 farmers with contiguous land (50 acre cluster) willing to adopt organic farming and PGS certification.",
            "requiredActions": [
              "Identify 20-50 farmers in your village/nearby area interested in organic farming",
              "Ensure cluster has minimum 50 acres contiguous cultivable land",
              "Hold meeting and get written consent from all farmers",
              "Elect cluster coordinator/lead farmer",
              "Apply to district agriculture department with cluster details",
            ],
            "url": "https://pgsindia-ncof.gov.in",
          },
          {
            "stepNumber": 2,
            "title": "Cluster Approval and PGS Enrollment",
            "description":
                "Get cluster approved by district/state agriculture department. Enroll in Participatory Guarantee System (PGS) for organic certification and training.",
            "requiredActions": [
              "Submit cluster proposal to District Level Monitoring Committee (DLMC)",
              "Attend training on organic farming practices and PGS certification",
              "Register cluster on PGS India portal for organic certification",
              "Prepare organic farming plan for 3-year conversion period",
              "Receive approval and cluster code for PKVY benefits",
            ],
            "url": "https://pgsindia-ncof.gov.in/PKVY/Index.aspx",
          },
          {
            "stepNumber": 3,
            "title": "Implement Organic Farming and Receive Assistance",
            "description":
                "Adopt organic practices, use bio-fertilizers and bio-pesticides. Receive ₹50,000 per hectare over 3 years for inputs, certification, labeling, and marketing support.",
            "requiredActions": [
              "Adopt organic farming practices (no chemical fertilizers/pesticides)",
              "Purchase organic inputs (compost, bio-fertilizers, bio-pesticides)",
              "Maintain records for PGS certification audits",
              "Participate in quality control and peer inspections",
              "Receive financial assistance: ₹31,000/ha in Year 1, ₹12,000/ha in Year 2-3",
            ],
            "url": "https://pgsindia-ncof.gov.in",
          },
        ],
        "startDate": "2015-05-01T00:00:00Z",
        "expiryDate": null,
        "applicationUrl": "https://pgsindia-ncof.gov.in",
        "helplineNumber": "011-23384646",
        "officialWebsite": "https://pgsindia-ncof.gov.in",
        "isActive": true,
        "benefitDetails": [
          "₹50,000 per hectare financial assistance over 3 years for organic conversion",
          "Free PGS certification for organic produce with quality assurance",
          "Training on organic farming, composting, and natural pest management",
          "Market linkages, branding support, and premium prices for certified organic produce",
        ],
        "departmentName":
            "Department of Agriculture and Farmers Welfare, Ministry of Agriculture",
        "source": "pgsindia-ncof.gov.in",
      },

      // Tractor Subsidy (State - Maharashtra Example)
      {
        "id": "tractor-subsidy-001",
        "name": "Tractor/Farm Mechanization Subsidy Scheme",
        "description":
            "State subsidy scheme for farm mechanization providing 50% subsidy on tractor purchase for small/marginal farmers to reduce drudgery and improve farm efficiency (Implementation varies by state).",
        "category": "Equipment Subsidy",
        "type": "State",
        "states": [
          "Maharashtra",
          "Karnataka",
          "Tamil Nadu",
          "Uttar Pradesh",
          "Punjab",
          "Haryana",
          "Rajasthan",
        ],
        "districts": [[]],
        "eligibilityCriteria": {
          "requiresAadhar": true,
          "requiresBankAccount": true,
          "maxLandHolding": 10,
          "minLandHolding": 1,
          "farmerCategories": ["Small", "Marginal"],
          "applicableCrops": ["All"],
        },
        "subsidyPercentage": 50,
        "maxSubsidyAmount": 200000,
        "minSubsidyAmount": 50000,
        "requiredDocuments": [
          "Aadhar Card",
          "Bank Account Details with IFSC",
          "Land Ownership Documents (7/12, 8A, Patta)",
          "Tractor Purchase Invoice and Bill",
          "Dealer Registration Certificate",
          "Caste Certificate (for additional subsidy - SC/ST)",
          "No Subsidy Certificate (not availed tractor subsidy before)",
        ],
        "applicationSteps": [
          {
            "stepNumber": 1,
            "title": "Check Eligibility and Select Tractor",
            "description":
                "Verify state-specific eligibility criteria and select approved tractor model from empaneled dealers. Ensure you haven't availed tractor subsidy in last 7 years.",
            "requiredActions": [
              "Check state agriculture department website for current subsidy scheme",
              "Verify eligible tractor models and approved dealers list",
              "Ensure land holding is within eligible limit (typically 1-10 acres)",
              "Confirm you haven't availed tractor subsidy in past 7-10 years",
              "Get quotation from authorized tractor dealer",
            ],
            "url": "https://mahadbt.maharashtra.gov.in (for Maharashtra)",
          },
          {
            "stepNumber": 2,
            "title": "Purchase Tractor and Apply for Subsidy",
            "description":
                "Purchase tractor from authorized dealer by paying full amount. Apply for subsidy reimbursement within 30 days through state DBT portal or agriculture office.",
            "requiredActions": [
              "Purchase tractor and pay full amount to dealer",
              "Get tax invoice, receipt, and tractor registration documents",
              "Apply online on state DBT portal within 30 days of purchase",
              "Upload invoice, land records, Aadhar, bank details, and photos",
              "Submit application and receive acknowledgment number",
            ],
            "url": "https://mahadbt.maharashtra.gov.in or state portal",
          },
          {
            "stepNumber": 3,
            "title": "Verification and Subsidy Disbursement",
            "description":
                "Agriculture officer will verify documents and conduct physical verification of tractor. After approval, 40-50% subsidy (up to ₹2 lakh) will be transferred to bank account.",
            "requiredActions": [
              "Coordinate with agriculture officer for document verification",
              "Allow physical verification of tractor at your farm",
              "Ensure tractor registration in your name with correct details",
              "Track application status on DBT portal using acknowledgment number",
              "Receive 40-50% subsidy (up to ₹2 lakh) in 30-60 days",
            ],
            "url": null,
          },
        ],
        "startDate": "2020-01-01T00:00:00Z",
        "expiryDate": "2026-03-31T23:59:59Z",
        "applicationUrl": "State DBT portals (varies by state)",
        "helplineNumber": "1800-120-8040 (Maharashtra), Varies by state",
        "officialWebsite": "State agriculture department websites",
        "isActive": true,
        "benefitDetails": [
          "40-50% subsidy on tractor purchase (up to ₹2 lakh for general, higher for SC/ST)",
          "Additional 5-10% subsidy for SC/ST/women farmers in some states",
          "Reduced farm drudgery and improved operational efficiency",
          "Option to use tractor for custom hiring to generate additional income",
        ],
        "departmentName": "State Agriculture Departments (varies by state)",
        "source": "State government portals",
      },
    ];
  }

  /// Convert detailed scheme map to GovernmentScheme object
  static GovernmentScheme? mapToGovernmentScheme(
    Map<String, dynamic> schemeData,
  ) {
    try {
      return GovernmentScheme(
        id: schemeData['id'] ?? '',
        name: schemeData['name'] ?? '',
        description: schemeData['description'] ?? '',
        category: schemeData['category'] ?? '',
        type: schemeData['type'] ?? '',
        states: List<String>.from(schemeData['states'] ?? []),
        districts:
            schemeData['districts'] != null &&
                (schemeData['districts'] as List).isNotEmpty
            ? List<String>.from(schemeData['districts'][0] ?? [])
            : [],
        eligibilityCriteria: Map<String, dynamic>.from(
          schemeData['eligibilityCriteria'] ?? {},
        ),
        subsidyPercentage: schemeData['subsidyPercentage']?.toDouble(),
        maxSubsidyAmount: schemeData['maxSubsidyAmount']?.toDouble(),
        minSubsidyAmount: schemeData['minSubsidyAmount']?.toDouble(),
        requiredDocuments: List<String>.from(
          schemeData['requiredDocuments'] ?? [],
        ),
        applicationSteps:
            (schemeData['applicationSteps'] as List<dynamic>?)
                ?.map(
                  (step) =>
                      ApplicationStep.fromMap(Map<String, dynamic>.from(step)),
                )
                .toList() ??
            [],
        startDate: schemeData['startDate'] != null
            ? DateTime.parse(schemeData['startDate'])
            : null,
        expiryDate: schemeData['expiryDate'] != null
            ? DateTime.parse(schemeData['expiryDate'])
            : null,
        applicationUrl: schemeData['applicationUrl'],
        helplineNumber: schemeData['helplineNumber'],
        officialWebsite: schemeData['officialWebsite'],
        isActive: schemeData['isActive'] ?? true,
        lastUpdated: DateTime.now(),
        benefitDetails: List<String>.from(schemeData['benefitDetails'] ?? []),
        departmentName: schemeData['departmentName'],
      );
    } catch (e) {
      developer.log(
        'Error converting scheme data: $e',
        name: 'SchemeDataExpander',
      );
      return null;
    }
  }

  /// Get all schemes as GovernmentScheme objects
  static List<GovernmentScheme> getAllSchemesAsObjects() {
    final schemeData = _getAllDetailedSchemes();
    return schemeData
        .map((data) => mapToGovernmentScheme(data))
        .where((scheme) => scheme != null)
        .cast<GovernmentScheme>()
        .toList();
  }

  /// Get scheme by ID as GovernmentScheme object
  static GovernmentScheme? getSchemeObjectById(String schemeId) {
    final schemeData = getDetailedSchemeById(schemeId);
    if (schemeData == null) return null;
    return mapToGovernmentScheme(schemeData);
  }

  /// Get all scheme IDs
  static List<String> getAllSchemeIds() {
    return _getAllDetailedSchemes().map((s) => s['id'] as String).toList();
  }

  /// Search schemes by name or description
  static List<Map<String, dynamic>> searchSchemes(String query) {
    final allSchemes = _getAllDetailedSchemes();
    final lowerQuery = query.toLowerCase();

    return allSchemes.where((scheme) {
      final name = (scheme['name'] as String).toLowerCase();
      final description = (scheme['description'] as String).toLowerCase();
      final category = (scheme['category'] as String).toLowerCase();

      return name.contains(lowerQuery) ||
          description.contains(lowerQuery) ||
          category.contains(lowerQuery);
    }).toList();
  }

  /// Get schemes by category
  static List<Map<String, dynamic>> getSchemesByCategory(String category) {
    final allSchemes = _getAllDetailedSchemes();
    return allSchemes
        .where((scheme) => scheme['category'] == category)
        .toList();
  }

  /// Get schemes by type (Central/State/District)
  static List<Map<String, dynamic>> getSchemesByType(String type) {
    final allSchemes = _getAllDetailedSchemes();
    return allSchemes.where((scheme) => scheme['type'] == type).toList();
  }

  /// Get schemes available in a specific state
  static List<Map<String, dynamic>> getSchemesByState(String state) {
    final allSchemes = _getAllDetailedSchemes();
    return allSchemes.where((scheme) {
      final states = List<String>.from(scheme['states'] ?? []);
      return states.contains('All') || states.contains(state);
    }).toList();
  }
}
