<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String root = "";
%>

<style>
    .agreement-container {
        max-width: 800px;
        margin: 0 auto;
        padding: 20px;
    }
    .agreement-content {
        background: white;
        border-radius: 10px;
        padding: 30px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    .agreement-title {
        color: #333;
        border-bottom: 2px solid #007bff;
        padding-bottom: 10px;
        margin-bottom: 30px;
    }
    .agreement-section {
        margin-bottom: 25px;
    }
    .agreement-section h6 {
        color: #007bff;
        font-weight: bold;
        margin-bottom: 15px;
    }
    .agreement-section ul {
        padding-left: 20px;
    }
    .agreement-section li {
        margin-bottom: 8px;
        line-height: 1.6;
    }
    .back-btn {
        margin-top: 30px;
    }
</style>

<div class="agreement-container">
    <div class="agreement-content">
            <h2 class="agreement-title">이용약관</h2>
            
            <div class="agreement-section">
                <h6>제1조 (목적)</h6>
                <p>본 약관은 핫플썰(이하 "회사")이 제공하는 서비스의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.</p>
            </div>
            
            <div class="agreement-section">
                <h6>제2조 (정의)</h6>
                <ul>
                    <li><strong>서비스:</strong> 핫플썰이 제공하는 모든 서비스</li>
                    <li><strong>이용자:</strong> 서비스에 접속하여 본 약관에 따라 서비스를 이용하는 회원 및 비회원</li>
                    <li><strong>회원:</strong> 서비스에 개인정보를 제공하여 회원등록을 한 자</li>
                    <li><strong>콘텐츠:</strong> 이용자가 서비스를 이용하면서 생성한 모든 정보</li>
                </ul>
            </div>
            
            <div class="agreement-section">
                <h6>제3조 (약관의 효력 및 변경)</h6>
                <ul>
                    <li>본 약관은 서비스 화면에 게시하거나 기타의 방법으로 회원에게 공지함으로써 효력이 발생합니다.</li>
                    <li>회사는 합리적인 사유가 발생할 경우에는 본 약관을 변경할 수 있으며, 약관이 변경되는 경우 변경된 약관의 내용과 시행일을 정하여, 시행일로부터 최소 7일 이전에 공지합니다.</li>
                    <li>회원이 변경된 약관에 동의하지 않는 경우, 서비스 이용을 중단하고 탈퇴할 수 있습니다.</li>
                </ul>
            </div>
            
            <div class="agreement-section">
                <h6>제4조 (회원가입 및 계정 관리)</h6>
                <ul>
                    <li>회원가입은 아이디, 비밀번호, 이메일 등 필수 정보를 기재하고 본 약관 및 개인정보처리방침에 동의함으로써 성립합니다.</li>
                    <li>회원은 본인의 계정을 타인에게 양도·대여할 수 없으며, 관리 소홀로 인한 문제에 대한 책임은 본인에게 있습니다.</li>
                    <li>회사는 다음 사유가 있는 경우 가입을 거부하거나 취소할 수 있습니다.</li>
                    <ul>
                        <li>가입신청자가 본 약관에 의하여 이전에 회원자격을 상실한 적이 있는 경우</li>
                        <li>실명이 아니거나 타인의 명의를 이용한 경우</li>
                        <li>허위의 정보를 기재하거나, 회사가 제시하는 내용을 기재하지 않은 경우</li>
                        <li>이용자의 귀책사유로 인하여 승인이 불가능하거나 기타 규정한 제반 사항을 위반하며 신청하는 경우</li>
                    </ul>
                </ul>
            </div>
            
            <div class="agreement-section">
                <h6>제5조 (서비스의 제공 및 변경)</h6>
                <ul>
                    <li>회사는 다음과 같은 업무를 수행합니다.</li>
                    <ul>
                        <li>핫플레이스 정보 제공 서비스</li>
                        <li>커뮤니티 서비스</li>
                        <li>기타 회사가 정하는 업무</li>
                    </ul>
                    <li>회사는 서비스의 기술적 사양의 변경 등의 경우에는 장차 체결되는 계약에 의해 제공할 서비스의 내용을 변경할 수 있습니다.</li>
                </ul>
            </div>
            
            <div class="agreement-section">
                <h6>제6조 (회원의 의무 및 금지행위)</h6>
                <p>회원은 다음 행위를 해서는 안 됩니다.</p>
                <ul>
                    <li>허위 정보 작성, 타인 개인정보 도용</li>
                    <li>음란물, 아동·청소년 유해 매체물, 폭력적·혐오적 게시물 게재</li>
                    <li>유흥업소, 퇴폐업소, 성매매 알선, 불법 도박 등 불법 행위 홍보</li>
                    <li>해당 행위 적발 시 즉시 게시물 삭제 및 아이디 영구 정지</li>
                    <li>타인의 명예 훼손, 모욕, 개인정보 노출, 저작권 침해</li>
                    <li>스팸, 상업적 광고 게시(사전 승인 없는 경우)</li>
                    <li>회사 서비스의 정상 운영을 방해하는 행위(해킹, 크롤링 등)</li>
                </ul>
            </div>
            
            <div class="agreement-section">
                <h6>제7조 (서비스 이용의 제한)</h6>
                <ul>
                    <li>회사는 이용자가 본 약관의 의무를 위반하거나 서비스의 정상적인 운영을 방해한 경우, 경고, 일시정지, 영구이용정지 등으로 서비스 이용을 단계적으로 제한할 수 있습니다.</li>
                    <li>회사는 전항에도 불구하고, 주민등록법을 위반한 명의도용 및 결제도용, 전화번호 도용, 기타 불법행위를 한 경우 즉시 영구이용정지를 할 수 있습니다.</li>
                </ul>
            </div>
            
            <div class="agreement-section">
                <h6>제8조 (서비스 이용의 중지 및 해지)</h6>
                <ul>
                    <li>회원은 언제든지 서비스 이용을 중지하고 탈퇴할 수 있습니다.</li>
                    <li>회사는 회원이 약관·법령을 위반한 경우 즉시 서비스 이용을 제한하거나 회원 자격을 박탈할 수 있습니다.</li>
                    <li>특히, 불법 행위(성매매, 퇴폐업소 홍보, 저작권 침해, 명예훼손 등)에 대해서는 사전 경고 없이 계정 영구 정지 및 법적 조치를 취할 수 있습니다.</li>
                    <li>회원은 언제든지 서비스 탈퇴를 요청할 수 있으며, 회사는 제재 이력 검토 후 관련 법령에 따라 보관기간 경과 시 개인정보를 파기합니다.</li>
                </ul>
            </div>
            
            <div class="agreement-section">
                <h6>제9조 (면책조항)</h6>
                <ul>
                    <li>회사는 천재지변 또는 이에 준하는 불가항력으로 인하여 서비스를 제공할 수 없는 경우에는 서비스 제공에 관한 책임이 면제됩니다.</li>
                    <li>회사는 이용자의 귀책사유로 인한 서비스 이용의 장애에 대하여는 책임을 지지 않습니다.</li>
                    <li>회사는 이용자가 서비스를 이용하여 기대하는 수익을 상실한 것에 대하여 책임을 지지 않으며 그 밖에 서비스를 통하여 얻은 자료로 인한 손해에 관하여는 책임을 지지 않습니다.</li>
                </ul>
            </div>
            
            <div class="agreement-section">
                <h6>제10조 (준거법 및 관할법원)</h6>
                <ul>
                    <li>본 약관은 대한민국 법률에 따라 규율되고 해석됩니다.</li>
                    <li>서비스 이용과 관련하여 회사와 이용자 간에 발생한 분쟁에 관한 소송은 민사소송법상의 관할법원에 제기합니다.</li>
                </ul>
            </div>
            
        <div class="text-center back-btn">
            <button type="button" class="btn btn-primary" onclick="history.back()">돌아가기</button>
        </div>
    </div>
</div>
