import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          '개인정보처리방침',
          style: TextStyle(
            fontSize: 22,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                'TimeCapsule이 운영하는 드래곤 불 앱 개인정보 처리 방침',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                '드래곤 불 앱은 개인 정보 보호 법을 준수하며, 관련 법령에 의거한 개인정보처리방침을 정하여 이용자 권익 보호에 최선을 다하고 있습니다. \n회사의 개인 정보 처리 방침은 다음과 같은 내용을 담고 있습니다.',
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                '제 1조 (개인정보의 처리목적)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                  '드래곤 불 앱은 개인정보를 다음 목적 이외의 용도로는 이용하지 않으며 이용 목적 등이 변경될 경우에는 동의를 받아 처리하겠습니다.'),
              const SizedBox(
                height: 10,
              ),
              const Text(
                '제 2조 (처리하는 개인정보 항목)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text('드래곤 불 앱은 다음의 개인정보 항목을 처리하고 있습니다.'),
              const SizedBox(
                height: 5,
              ),
              Table(
                border: TableBorder.all(color: Colors.black),
                children: const [
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        '수집 시점',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        '처리 목적',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        '수집 항목',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        '앱 회원 가입 시',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        '사용자 관리',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        '필수 : 이메일 주소, 별명',
                      ),
                    )
                  ]),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                  '서비스 이용 과정이나 사업 처리 과정에서 아래와 같은 정보들이 자동으로 생성되어 수집 될 수 있습니다.'),
              const Text('- 이용자의 사용 기록'),
              const SizedBox(
                height: 10,
              ),
              const Text(
                '제 3조 (개인정보의 처리 및 보유 기간)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text('수집 및 이용 목적의 달성 또는 회원 탈퇴 등 파기 사유가 발생한 개인정보는 안전하게 파기합니다.'),
              const Text('수집 된 개인정보 : 1년'),
              const SizedBox(
                height: 10,
              ),
              const Text(
                '제 4조 (개인정보의 제 3자 제공)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                  '드래곤 불 앱은 개인정보를 “제 1조 개인정보의 처리 목적”과 “제 2조 처리하는 개인정보 항목”에서 고지한 범위 내에서 사용하며, 정보 주체의 사전 동의 없이는 동 범위를 초과하여 이용하거나 원칙적으로 개인정보를 외부에 공개하지 않습니다.'),
              const SizedBox(
                height: 10,
              ),
              const Text(
                '제 5조 (개인정보처리의 위탁)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text('드래곤 불 앱은 개인정보처리를 따로 위탁하지 않습니다.'),
              const SizedBox(
                height: 10,
              ),
              const Text(
                '제 6조 (정보 주체의 권리 의무 및 행사 방법)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                  '정보 주체는 드래곤 불 앱에 대해 언제든지 개인정보 열람·정정·삭제·처리정지 요구 등의 권리를 행사할 수 있습니다.'),
              const Text(
                  '- 드래곤 불 앱에 대해 개인정보 보호법 시행령 제41조제1항에 따라 서면, 전화 등을 통하여 하실 수 있으며, 드래곤 불 앱은 이에 대해 지체 없이 조치하겠습니다.'),
              const Text(
                  '- 정보 주체의 법정 대리인이나 위임을 받은 자 등 대리인을 통하여 하실 수 있습니다. 이 경우 개인정보 보호법 시행규칙 별지 제11호 서식에 따른 위임장을 제출하셔야 합니다.'),
              const Text(
                  '- 개인정보 열람 및 처리 정지 요구는 개인정보보호법 제35조 제5항, 제37조 제2항에 의하여 정보주체의 권리가 제한 될 수 있습니다.'),
              const Text(
                  '- 개인정보의 정정 및 삭제 요구는 다른 법령에서 그 개인정보가 수집 대상으로 명시되어 있는 경우에는 그 삭제를 요구할 수 없습니다.'),
              const Text(
                  '- 한국표준정보망은 정보 주체 권리에 따른 열람의 요구, 정정·삭제의 요구, 처리 정지의 요구 시 열람 등 요구를 한 자가 본인이거나 정당한 대리인 인지를 확인합니다. '),
              const SizedBox(
                height: 10,
              ),
              const Text(
                '제 7조 (개인정보의 파기)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                  '드래곤 불 앱은 개인정보 보유 기간의 경과, 처리 목적 달성 등 개인정보가 불필요하게 되었을 때에는 다음과 같이 지체 없이 해당 개인정보를 파기합니다.'),
              const Text('파기 절차 '),
              const Text(
                  '- 불필요한 개인정보 및 개인 정보 파일은 “제 3조 개인정보의 처리 및 보유 기간”에 따라 지체 없이 파기합니다.'),
              const Text('파기 방법'),
              const Text(
                  '- 전자적 형태의 개인정보는 기록을 재생할 수 없는 기술적 방법을 사용하며, 종이에 출력 되는 개인정보는 분쇄기로 분쇄하거나 소각을 통하여 파기합니다.'),
              const SizedBox(
                height: 10,
              ),
              const Text(
                '제 8조 (개인정보의 안정성 확보 조치)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                  '드래곤 불 앱은 「개인정보보호법」 제 29조에 따라 개인정보의 안정성 확보를 위해 다음과 같은 조치를 취하고 있습니다.'),
              const Text('1. 관리적 조치'),
              const Text('내부 관리 계획 수립/시행, 정기적인 취급자 교육 등'),
              const Text('2. 기술적 조치'),
              const Text('개인 정보 처리 시스템 등의 접근 권한 관리, 보안 프로그램 설치'),
              const Text('3. 물리적 조치'),
              const Text('자료 보관실 등의 접근 통제'),
              const SizedBox(
                height: 10,
              ),
              const Text(
                '제 9조 (개인정보 보호 책임자 및 연락처)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                  '드래곤 불 앱은 개인정보를 보호하고 개인정보와 관련된 사항을 처리하기 위하여 민원을 개인정보 보호 책임자에게 신고하실 수 있습니다.\n드래곤 불 앱은 이용자들의 신고 사항에 대해 신속하게 충분한 답변을 드릴 것입니다.'),
              Table(
                border: TableBorder.all(color: Colors.black),
                children: const [
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        '직위',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        '책임자',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        '전화번호',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        '팀장',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        '김의년',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'youkids604@gmail.com',
                      ),
                    )
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'DB팀장',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        '김선우',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'youkids604@gmail.com',
                      ),
                    )
                  ]),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                '제 10조 (권익 침해 구제 방법)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                  '정보 주체는 개인 정보 침해로 인한 구제를 받기 위하여 개인정보분쟁조정위원회, 한국인터넷진흥원 개인정보침해신고센터 등에 분쟁 해결이나 상담 등을 신청할 수 있습니다. 이밖에 기타 개인 정보 침해의 신고, 상담에 대하여는 아래의 기관에 문의하시기 바랍니다.'),
              const Text('개인정보 침해 신고 센터 (한국인터넷진흥원 운영) '),
              const Text(
                  '- (국번없이 118 / privacy.kisa.or.kr) 소관 업무 : 개인정보 침해 사실 신고, 상담 신청'),
              const Text('개인정보 분쟁 조정 위원회  '),
              const Text(
                  '- (국번없이 118 / www.kopico.go.kr) 소관 업무 : 개인정보 분쟁 조정 신청, 집단 분쟁 조정 (민사적 해결)'),
              const Text('대검찰청 사이버 범죄 수사단'),
              const Text('- (국번없이 1301 / (www.spo.go.kr)'),
              const Text('경찰청 사이버 안전국'),
              const Text('-  (국번없이 182 / cyberbureau.police.go.kr)'),
              const SizedBox(
                height: 10,
              ),
              const Text(
                '제 11조(개인정보 자동 수집 장치의 설치·운영 및 거부에 관한 사항)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                  '드래곤 불 앱은 앱 서비스를 제공하기 위해 ‘클릭 정보’를 수집합니다. 클릭 정보는 웹사이트를 운영하는데 이용되고 서버가 이용자의 앱에 보내는 소량의 정보이며 이용자들의 앱 내에 저장될 수 있습니다.'),
              const Text('- 사용 목적'),
              const Text('이용자가 방문한 앱 페이지에 대한 방문 등을 파악하기 위해 사용합니다.'),
              const SizedBox(
                height: 10,
              ),
              const Text(
                '제 12조 (개인정보 처리 방침 변경)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                  '현 개인정보처리방침의 내용 추가, 삭제 및 수정이 있을 시에는 개정 최소 7일전부터 앱 공지사항을 통해 고지할 것 입니다. \n다만, 개인정보의 수집 및 활용, 제 3자 제공 등과 같이 이용자 권리의 중요한 변경이 있을 경우에는 최소 30일전에 고지합니다'),
              const Text('- 시행일자 : 2023년 10월 30일')
            ]),
          )),
    );
  }
}
