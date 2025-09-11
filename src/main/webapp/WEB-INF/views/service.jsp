<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String root = request.getContextPath();
%>

<style>
    .privacy-container {
        max-width: 800px;
        margin: 0 auto;
        padding: 20px;
    }
    .privacy-content {
        background: white;
        border-radius: 10px;
        padding: 30px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    .privacy-title {
        color: #333;
        border-bottom: 2px solid #007bff;
        padding-bottom: 10px;
        margin-bottom: 30px;
    }
    .privacy-section {
        margin-bottom: 25px;
    }
    .privacy-section h6 {
        color: #007bff;
        font-weight: bold;
        margin-bottom: 15px;
    }
    .privacy-section ul {
        padding-left: 20px;
    }
    .privacy-section li {
        margin-bottom: 8px;
        line-height: 1.6;
    }
    .back-btn {
        margin-top: 30px;
    }
</style>

<div class="privacy-container">
    <div class="privacy-content">
            <h2 class="privacy-title">개인정보처리방침</h2>
            
            <div class="privacy-section">
                <h6>제1조 (수집하는 개인정보 항목)</h6>
                
                <p><strong>필수 항목</strong></p>
                <ul>
                    <li>아이디, 비밀번호, 이메일, 닉네임</li>
                    <li>휴대폰 번호 (본인 인증용)</li>
                </ul>
                
                <p><strong>선택 항목</strong></p>
                <ul>
                    <li>프로필 사진, 관심 지역, 성별, 생년월일</li>
                </ul>
            </div>
            
            <div class="privacy-section">
                <h6>제2조 (개인정보의 수집 및 이용 목적)</h6>
                <p>회사는 수집한 개인정보를 다음 목적을 위해 이용합니다.</p>
                <ul>
                    <li><strong>회원 가입 및 관리:</strong> 본인 확인, 중복가입 방지, 계정 관리</li>
                    <li><strong>서비스 제공:</strong> 후기 작성, 투표, 찜하기, 위시리스트, 커뮤니티 활동</li>
                    <li><strong>고객 지원:</strong> 문의사항 처리, 서비스 개선</li>
                    <li><strong>보안 관리:</strong> 불법 이용 방지, 비정상 이용 탐지 및 제재 이력 관리</li>
                </ul>
            </div>
            
            <div class="privacy-section">
                <h6>제3조 (개인정보의 보유 및 이용 기간)</h6>
                <p>원칙적으로 회원이 탈퇴를 요청하면 지체 없이 개인정보를 파기합니다.</p>
                <p>단, 다음의 경우에는 일정 기간 보관 후 파기합니다.</p>
                <ul>
                    <li>운영 정책 위반, 서비스 제재 이력 검토를 위해 최대 30일간 임시 보관</li>
                    <li>관련 법령에 의해 보관이 의무화된 경우 해당 법령에서 정한 기간</li>
                    <li>분쟁 해결을 위해 필요한 경우 해당 분쟁이 해결될 때까지</li>
                </ul>
                <p>위 기간이 지나면 해당 정보는 지체 없이 안전하게 파기합니다.</p>
            </div>
            
            <div class="privacy-section">
                <h6>제4조 (개인정보 제3자 제공 및 위탁)</h6>
                <p>회사는 원칙적으로 회원 동의 없이 개인정보를 제3자에게 제공하지 않습니다.</p>
                <p>서비스 운영을 위해 다음과 같이 위탁할 수 있습니다.</p>
                <ul>
                    <li>이메일 발송: Brevo (Sendinblue)</li>
                    <li>소셜 로그인: 네이버 OAuth2</li>
                    <li>클라우드/호스팅: (사용 중인 서버 사업자 기재)</li>
                </ul>
                <p>회사는 위탁 계약 시 개인정보 보호 관련 법령을 준수합니다.</p>
            </div>
            
            <div class="privacy-section">
                <h6>제5조 (동의 거부 권리 및 불이익)</h6>
                <p>회원은 개인정보 수집·이용에 동의하지 않을 권리가 있습니다.</p>
                <p>단, 필수 항목에 동의하지 않을 경우 회원가입 및 서비스 이용이 불가능합니다.</p>
            </div>
            
            <div class="privacy-section">
                <h6>제6조 (개인정보 보호책임자)</h6>
                <p>개인정보 처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 정보주체의 불만처리 및 피해구제 등을 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있습니다.</p>
                <ul>
                    <li><strong>개인정보 보호책임자:</strong> 조태민</li>
                    <li><strong>연락처:</strong> hothot0001122@gmail.com</li>
                </ul>
            </div>
            
            <div class="privacy-section">
                <h6>제7조 (개인정보 처리방침의 변경)</h6>
                <p>이 개인정보처리방침은 시행일로부터 적용되며, 법령 및 방침에 따른 변경내용의 추가, 삭제 및 정정이 있는 경우에는 변경사항의 시행 7일 전부터 공지사항을 통하여 고지할 것입니다.</p>
            </div>
            
        <div class="text-center back-btn">
            <button type="button" class="btn btn-primary" onclick="history.back()">돌아가기</button>
        </div>
    </div>
</div>
