import SwiftUI

// MARK: - Data Protection & GDPR View

struct DataProtectionView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Data Protection & Privacy")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.slate900)
                        
                        Text("GDPR & CCPA Compliance")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(AppTheme.slate600)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Section("GDPR Compliance (EU Users)") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Under the General Data Protection Regulation (GDPR), you have the following rights:")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppTheme.slate700)
                                
                                ProtectionRight(
                                    title: "Right to Access",
                                    description: "You have the right to request access to your personal data and receive a copy of the data we hold about you."
                                )
                                
                                ProtectionRight(
                                    title: "Right to Rectification",
                                    description: "You can request correction of inaccurate or incomplete personal data."
                                )
                                
                                ProtectionRight(
                                    title: "Right to Erasure",
                                    description: "Under certain circumstances, you can request deletion of your personal data (the \"right to be forgotten\")."
                                )
                                
                                ProtectionRight(
                                    title: "Right to Data Portability",
                                    description: "You can request your data in a structured, commonly used, machine-readable format."
                                )
                                
                                ProtectionRight(
                                    title: "Right to Object",
                                    description: "You can object to processing of your data for marketing purposes."
                                )
                                
                                ProtectionRight(
                                    title: "Right to Lodge a Complaint",
                                    description: "You can file a complaint with your local data protection authority."
                                )
                            }
                        }
                        
                        Section("CCPA Compliance (California Users)") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Under the California Consumer Privacy Act (CCPA), California residents have the right to:")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppTheme.slate700)
                                
                                BulletPoint("Know what personal information we collect, use, and share")
                                BulletPoint("Delete personal information collected from you")
                                BulletPoint("Opt-out of selling or sharing your personal information")
                                BulletPoint("Non-discrimination for exercising your CCPA rights")
                            }
                        }
                        
                        Section("Data Retention") {
                            Text("We retain your personal data only for as long as necessary to provide our services or as required by law. When you delete your account, we delete or anonymize your data within 30 days, unless legal obligations require us to retain it.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                        
                        Section("Data Security") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("We implement industry-standard security measures:")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppTheme.slate700)
                                
                                BulletPoint("End-to-end encryption for sensitive data")
                                BulletPoint("Secure SSL/TLS connections")
                                BulletPoint("Regular security audits and penetration testing")
                                BulletPoint("Restricted access to personal data")
                                BulletPoint("Employee confidentiality agreements")
                                BulletPoint("Data breach notification procedures")
                            }
                        }
                        
                        Section("International Transfers") {
                            Text("Your information may be transferred to, stored in, and processed in countries other than the country in which you reside. These countries may have data protection laws that differ from your home country. By using CreatorBridge, you consent to such transfers.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                        
                        Section("Exercise Your Rights") {
                            Text("To exercise any of these rights, please submit a request to privacy@creatorbridge.com with your account details. We will respond within 30 days or as required by applicable law.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                    }
                }
                .padding(20)
            }
            .background(
                colorScheme == .dark ?
                AppTheme.slate900 : Color.white
            )
            .navigationTitle("Data Protection")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Help & Support View

struct HelpSupportView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var expandedSection: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Help & Support")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.slate900)
                        
                        Text("Find answers to common questions")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(AppTheme.slate600)
                    }
                    
                    // Contact Support
                    VStack(spacing: 12) {
                        Text("Contact Us")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.slate900)
                        
                        SupportContactButton(
                            icon: "envelope",
                            title: "Email Support",
                            subtitle: "support@creatorbridge.com",
                            action: { }
                        )
                        
                        SupportContactButton(
                            icon: "message",
                            title: "Live Chat",
                            subtitle: "Available 9 AM - 6 PM EST",
                            action: { }
                        )
                        
                        SupportContactButton(
                            icon: "info.circle",
                            title: "Help Center",
                            subtitle: "Browse articles and guides",
                            action: { }
                        )
                    }
                    .padding(16)
                    .background(AppTheme.slate100)
                    .cornerRadius(12)
                    
                    // FAQ
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Frequently Asked Questions")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.slate900)
                        
                        FAQItem(
                            question: "How do I sign up?",
                            answer: "Click 'I am a Creator' or 'I am a Brand' on the home screen, fill in your details, and verify your email. You'll be ready to start in minutes!",
                            isExpanded: expandedSection == "q1"
                        ) {
                            expandedSection = expandedSection == "q1" ? nil : "q1"
                        }
                        
                        FAQItem(
                            question: "How do I get paid?",
                            answer: "Once you complete a campaign, the brand approves your work, and payment is processed to your connected bank account within 24-48 hours. You can track payments in your Earnings dashboard.",
                            isExpanded: expandedSection == "q2"
                        ) {
                            expandedSection = expandedSection == "q2" ? nil : "q2"
                        }
                        
                        FAQItem(
                            question: "What are the fees?",
                            answer: "CreatorBridge takes a 10% platform fee on completed campaigns. This helps us maintain and improve the platform. Creators keep 90% of their earnings.",
                            isExpanded: expandedSection == "q3"
                        ) {
                            expandedSection = expandedSection == "q3" ? nil : "q3"
                        }
                        
                        FAQItem(
                            question: "How do I report a problem?",
                            answer: "Use the Report button in the app, or contact support@creatorbridge.com. Include details about the issue and we'll investigate within 24 hours.",
                            isExpanded: expandedSection == "q4"
                        ) {
                            expandedSection = expandedSection == "q4" ? nil : "q4"
                        }
                        
                        FAQItem(
                            question: "Can I delete my account?",
                            answer: "Yes, you can delete your account anytime in Settings > Account. Your data will be permanently deleted within 30 days. Completed campaigns and payments history will remain for tax purposes.",
                            isExpanded: expandedSection == "q5"
                        ) {
                            expandedSection = expandedSection == "q5" ? nil : "q5"
                        }
                        
                        FAQItem(
                            question: "Is my payment information safe?",
                            answer: "Yes. We use industry-standard encryption and never store your full payment details. All transactions are processed through PCI-DSS compliant payment processors.",
                            isExpanded: expandedSection == "q6"
                        ) {
                            expandedSection = expandedSection == "q6" ? nil : "q6"
                        }
                    }
                    
                    // Status Page
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Service Status")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.slate900)
                        
                        HStack {
                            Circle()
                                .fill(AppTheme.successGreen)
                                .frame(width: 10, height: 10)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("All Systems Operational")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.slate900)
                                
                                Text("Last checked: Just now")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(AppTheme.slate600)
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                        .background(AppTheme.successGreen.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Resources
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Resources")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.slate900)
                        
                        NavigationLink(destination: PrivacyPolicyFullView()) {
                            ResourceLink(title: "Privacy Policy", icon: "lock")
                        }
                        
                        NavigationLink(destination: TermsOfServiceFullView()) {
                            ResourceLink(title: "Terms of Service", icon: "doc")
                        }
                        
                        NavigationLink(destination: CommunityGuidelinesView()) {
                            ResourceLink(title: "Community Guidelines", icon: "person.2")
                        }
                        
                        NavigationLink(destination: DataProtectionView()) {
                            ResourceLink(title: "Data Protection", icon: "shield")
                        }
                    }
                }
                .padding(20)
            }
            .background(
                colorScheme == .dark ?
                AppTheme.slate900 : Color.white
            )
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Refund Policy View

struct RefundPolicyView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Refund Policy")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.slate900)
                        
                        Text("Payment and refund terms")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(AppTheme.slate600)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Section("1. Campaign Cancellation") {
                            Text("Brands may cancel a campaign before work begins. In this case, the creator is not entitled to payment. If work has commenced, partial payment may be negotiated.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                        
                        Section("2. Dispute Resolution") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("If there's a dispute about deliverables:")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppTheme.slate700)
                                
                                BulletPoint("Contact our dispute team at disputes@creatorbridge.com")
                                BulletPoint("Both parties must provide evidence and documentation")
                                BulletPoint("We investigate within 5 business days")
                                BulletPoint("Final decision is binding")
                            }
                        }
                        
                        Section("3. Refund Eligibility") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Refunds may be granted if:")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppTheme.slate700)
                                
                                BulletPoint("Deliverables don't meet agreed specifications")
                                BulletPoint("Creator fails to deliver within timeframe")
                                BulletPoint("Work quality is demonstrably substandard")
                                BulletPoint("Creator violates community guidelines")
                            }
                        }
                        
                        Section("4. Non-Refundable Items") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("The following are non-refundable:")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppTheme.slate700)
                                
                                BulletPoint("Platform fees already processed")
                                BulletPoint("Completed campaigns (unless disputed)")
                                BulletPoint("Subscription upgrades (monthly renewal)")
                            }
                        }
                        
                        Section("5. Chargeback Policy") {
                            Text("Initiating a chargeback without first contacting us will result in account suspension. We will vigorously dispute chargebacks that violate this policy.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                        
                        Section("6. Refund Timeline") {
                            Text("Approved refunds are processed within 5-7 business days to the original payment method. Bank processing times may add 2-5 additional days.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                    }
                }
                .padding(20)
            }
            .background(
                colorScheme == .dark ?
                AppTheme.slate900 : Color.white
            )
            .navigationTitle("Refund Policy")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Helper Components

struct ProtectionRight: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.slate900)
            
            Text(description)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(AppTheme.slate700)
                .lineSpacing(2)
        }
        .padding(12)
        .background(AppTheme.primaryLight)
        .cornerRadius(8)
    }
}

struct SupportContactButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.primary)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.primaryLight)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.slate900)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppTheme.slate600)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .foregroundColor(AppTheme.slate400)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(8)
        }
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    let isExpanded: Bool
    let toggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: toggle) {
                HStack {
                    Text(question)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.slate900)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundColor(AppTheme.slate400)
                }
                .padding(12)
            }
            
            if isExpanded {
                Divider()
                    .padding(0)
                
                Text(answer)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(AppTheme.slate700)
                    .lineSpacing(2)
                    .padding(12)
            }
        }
        .background(Color.white)
        .cornerRadius(8)
        .border(AppTheme.slate300, width: 1)
    }
}

struct ResourceLink: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.primary)
                .font(.system(size: 16, weight: .semibold))
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.slate900)
            
            Spacer()
            
            Image(systemName: "arrow.right")
                .foregroundColor(AppTheme.slate400)
        }
        .padding(12)
        .background(AppTheme.slate100)
        .cornerRadius(8)
    }
}

#Preview {
    HelpSupportView()
}
