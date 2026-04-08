### รายงานสรุป: การสร้าง Custom Controls ด้วย Xojo WebSDK

#### 1\. บทนำและแนวคิดพื้นฐานของ WebSDK 2.0

ในฐานะสถาปนิกซอฟต์แวร์ วิสัยทัศน์เบื้องหลัง Xojo Web 2.0 คือการมอบเฟรมเวิร์กที่มีความยืดหยุ่นและขยายขีดความสามารถได้ (Extensibility) โดย Xojo ได้ออกแบบให้มี SDK พร้อมใช้งานตั้งแต่วันแรก เพื่อให้คอนโทรลที่คุณสร้างขึ้นเองมีมาตรฐานและประสิทธิภาพเทียบเท่ากับคอนโทรลที่มากับระบบ (Built-in controls)**เป้าหมายหลักเชิงกลยุทธ์:**

* **การลดความหน่วง (Latency):**  ย้ายภาระการประมวลผลบางส่วนไปที่เบราว์เซอร์ เพื่อให้ UI ตอบสนองได้ทันที (Real-time) โดยไม่ต้องรอรอบการสื่อสารจากเซิร์ฟเวอร์  
* **การบูรณาการห้องสมุดภายนอก (Third-party Integration):**  เปิดประตูสู่โลกของ JavaScript Libraries เช่น ระบบ Charting ขั้นสูง หรือ Bootstrap Components ที่ Xojo ยังไม่มีให้ (เช่น Toast Notifications)**กฎเหล็กเรื่อง Namespaces และการตั้งชื่อ:**  เพื่อความเป็นมืออาชีพและป้องกันความขัดแย้งของโค้ด (Namespace Collision) ในระบบที่มีความซับซ้อน:  
* **Namespace Registry:**  คุณต้องใช้ Namespace ของตนเอง (เช่น Acme) และห้ามใช้คำว่า "Xojo" นำหน้าเด็ดขาด  
* **Naming Convention:**  แนะนำให้ใช้ Prefix นำหน้าชื่อ Class (เช่น Acme\_Button) เพื่อความชัดเจนใน Navigator และ Library

#### 2\. สถาปัตยกรรมแบบ Full Stack และการสื่อสาร

Xojo Web แตกต่างจากเฟรมเวิร์กอื่นด้วยแนวคิด  **"Blurry Line"**  ที่ประสาน Front-end และ Back-end เข้าด้วยกันอย่างไร้รอยต่อ โดย Xojo จะจัดการ Communication Layer (Websocket/HTTP) ให้โดยอัตโนมัติ ทำให้นักพัฒนาไม่ต้องเสียเวลาสร้าง REST API**การแยกความรับผิดชอบ (Separation of Logic):**

* **Server-side (Xojo):**  รับผิดชอบ Business Logic และการตัดสินใจเชิงกลยุทธ์เมื่อเกิดเหตุการณ์ (Events)  
* **Browser-side (JavaScript):**  รับผิดชอบการวาดหน้าจอ (Rendering) และการจัดการ DOM ภายในพื้นที่ของคอนโทรลตนเอง  
* **Architect's Insight:**  ห้ามประมวลผล HTML/DOM ที่ฝั่ง Server โดยเด็ดขาด เพื่อลดปริมาณ Traffic และช่วยให้การ Debug ทำได้ตรงจุด

#### 3\. การเปรียบเทียบ: Custom Controls (Containers) vs. WebSDK

การเลือกใช้เครื่องมือที่เหมาะสมกับงานเป็นทักษะสำคัญของ Architect:| คุณสมบัติ | การใช้ Container (Standard) | การใช้ WebSDK (Advanced) || \------ | \------ | \------ || **กลไกการทำงาน** | นำคอนโทรลมาตรฐานมาประกอบกัน | สร้างขึ้นใหม่จาก Class พื้นฐาน || **จุดเด่น** | พัฒนาเร็ว ไม่ต้องรู้ JavaScript | ปรับแต่งได้ระดับ Pixel และลด Latency || **การตอบสนอง** | มีความหน่วง (Round-trip) | Real-time (Execute on browser) || **กรณีศึกษา** | Text Area ที่อัปเดตตัวนับเมื่อเสีย Focus | Text Area ที่นับตัวอักษร "ทันทีขณะพิมพ์" |

#### 4\. เครื่องมือและสภาพแวดล้อมการพัฒนา (Development Tooling)

เราแนะนำอย่างยิ่งให้ใช้  **TypeScript**  แทน JavaScript บริสุทธิ์ เพื่อลดความเสี่ยงในการเกิด Runtime Error และเพิ่มความเร็วในการเขียนโค้ดด้วยระบบ Autocomplete (ผ่านไฟล์ XojoWebSDK.d.ts)**Workflow สำหรับนักพัฒนามืออาชีพ:**

* **Environment:**  ติดตั้ง  **Node.js**  เพื่อใช้ TypeScript Compiler (tsc)  
* **Configuration (**  **tsconfig.json**  **):**  
* target: "ES2015" (เพื่อรองรับ Edge 12+)  
* outFile: กำหนดจุดรวมไฟล์ JavaScript ผลลัพธ์  
* **Efficiency:**  ใช้คำสั่ง tsc \-w (Watch mode) เพื่อให้คอมไพล์ใหม่ทันทีที่มีการบันทึกไฟล์

#### 5\. โครงสร้างของ Custom Control (Class Hierarchy)

ความเข้าใจเรื่องลำดับชั้นของคลาสเป็นรากฐานของการเขียนโปรแกรมเชิงวัตถุใน WebSDK:

* **Visual Controls (มีหน้าจอ):**  
* Xojo: WebSDKUIControl (สืบทอดจาก WebUIControl  **ไม่ใช่**  WebSDKControl)  
* JavaScript: XojoVisualControl  
* **Non-Visual Controls (ไม่มีหน้าจอ เช่น Timer):**  
* Xojo: WebSDKControl  
* JavaScript: XojoControl  
* **Key Constant:**  ในฝั่ง Xojo จะมีค่า APIVersion (ปัจจุบันคือเวอร์ชัน 7\) เพื่อระบุเวอร์ชันของ SDK ที่ใช้งาน**Method พื้นฐานที่ต้องมีใน JavaScript:**

constructor(id: string, events: string\[\]) {   
    super(id, events); // ต้องเรียก super เสมอ  
}  
updateControl(data: string) { /\* รับค่า JSON จาก Server \*/ }  
render() { /\* วาด DOM ของคอนโทรล \*/ }

#### 6\. วงจรชีวิตการอัปเดตสถานะและการสื่อสาร (The Glue Code)

การรับส่งข้อมูลระหว่างสองฝั่งมีขั้นตอนที่ต้องปฏิบัติตามอย่างเคร่งครัด:**การอัปเดตจาก Server ไปยัง Browser (Update State):**

* **Xojo:**  เรียกใช้ UpdateControl(sendImmediately: Boolean)  
* หากส่ง True: ข้อมูลจะไปทันที  
* หากส่ง False: จะรอจนจบ Event Loop (Deferred) เพื่อประสิทธิภาพ  
* *ทางเลือก:*  ใช้ UpdateBrowser() เพื่อส่งข้อมูลทันทีโดยไม่มีพารามิเตอร์  
* **Xojo:**  Event Serialize(js as JSONItem) จะทำงานเพื่อเตรียมข้อมูล  
* **JavaScript:**  รับข้อมูลที่ updateControl(data) จากนั้นต้องเรียก this.refresh()  
* **Architect's Insight:**   **ห้ามเรียก**  **render()**  **โดยตรง**  ให้เรียกผ่าน refresh() เพื่อให้เฟรมเวิร์กทำ  **Coalesce repeated calls**  (รวมการวาดซ้ำที่ซ้อนกัน) ช่วยเพิ่มประสิทธิภาพอย่างมหาศาล**การส่งเหตุการณ์กลับ (Browser to Server):**  
* **JavaScript:**  ใช้ triggerServerEvent(eventName, parameters)  
* **Xojo:**  รับข้อมูลที่ Event ExecuteEvent(name as String, parameters as JSONItem)

#### 7\. การรวมเข้ากับ Xojo IDE (Design Time Integration)

เพื่อให้คอนโทรลของคุณใช้งานง่ายใน Layout Editor:

* **Visual Feedback:**  ใช้ Event DrawControlInLayoutEditor ร่วมกับ Graphics API 2 ในการวาดภาพตัวอย่าง  
* **Property Access:**  ดึงค่าที่ผู้ใช้ตั้งใน Inspector ผ่าน Method เช่น StringProperty, ColorProperty หรือ ConstantValue  
* **Troubleshooting:**  หากโค้ดใน Layout Editor มีปัญหา Xojo จะแสดง  **Amber warning icon (ไอคอนสามเหลี่ยมสีส้ม)**  และคุณสามารถดูรายละเอียด Error ได้ที่ Messages panel  
* **Icons:**  กำหนด NavigatorIcon และ LibraryIcon ด้วยข้อมูลภาพแบบ Base64

#### 8\. ขั้นตอนการ Compile และการทดสอบ (Workflow & Deployment)

1. **Development Phase:**  ใช้  **Build Step**  เพื่อดึงไฟล์ JavaScript จากดิสก์โดยตรง ช่วยให้แก้ไขโค้ดและรันเพื่อดูผลได้ทันที  
2. **Distribution Phase:**  เมื่อพัฒนาเสร็จ ให้คัดลอกโค้ดที่คอมไพล์แล้วใส่ไว้ใน  **Constant**  ภายในคอนโทรล เพื่อความสะดวกในการแจกจ่ายเป็นไฟล์เดียว  
3. **Session Setup:**  ใน Event SessionJavaScriptURLs เมื่อสร้าง WebFile ให้ตั้งค่า Session \= nil เสมอ เพื่อให้ไฟล์ JavaScript พร้อมใช้งานสำหรับผู้ใช้ทุกคนโดยไม่มีปัญหาเรื่องสิทธิ์การเข้าถึง

#### 9\. ข้อควรระวังและแนวทางปฏิบัติที่ดี (Best Practices)

* **กฎเหล็กเรื่อง Base64 (Thai/Non-ASCII):**  เมื่อต้องรับส่งข้อมูลภาษาไทย ในฝั่ง Xojo คุณต้องกำหนดพารามิเตอร์ length เป็น 0 เสมอ เช่น EncodeBase64(data, 0\) มิฉะนั้นการถอดรหัสในฝั่ง JavaScript จะผิดพลาด  
* **DOM Movement:**  พึงระลึกเสมอว่าคอนโทรลของคุณ  **"อาจเคลื่อนที่ภายใน DOM"**  (May move within the DOM) ตามการจัด Layout ของเฟรมเวิร์ก การเขียน JavaScript Selector จึงต้องระมัดระวัง  
* **Bandwidth & Memory:**  ควรทำ  **Throttle**  สำหรับ Event ที่เกิดขึ้นถี่ (เช่น MouseMove) เพื่อไม่ให้ Server ทำงานหนักเกินไป  
* **Professional Debugging:**  
* ใช้ XojoWeb.isDebugMode() เพื่อแยกโค้ด Development/Production  
* ใช้ XojoWeb.XojoConsole.log(msg, always) สำหรับ Log ที่ทำงานเฉพาะตอน Debug  
* ใช้ DebugLog(msg) ใน Xojo เพื่อส่งข้อความไปที่ Messages pane ของ IDE  
* **Namespace Security:**  ห้ามแก้ไข XojoWeb namespace หรือดัดแปลง DOM ของคอนโทรลอื่นเด็ดขาด เพื่อความเสถียรของระบบโดยรวม

