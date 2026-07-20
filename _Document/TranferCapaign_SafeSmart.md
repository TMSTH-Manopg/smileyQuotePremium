# คู่มืออธิบายการทำงานโปรแกรม Transfer Campaign To Safe Smart

## วัตถุประสงค์
โปรแกรมนี้ใช้สำหรับ Transfer ข้อมูล Campaign Motor จากฐานข้อมูลต้นทาง ไปยัง Safe Smart ผ่าน Web Service โดยมีขั้นตอน Export, Sync ตาราง, สร้าง Parameter และเรียก Service อัตโนมัติ

---

# ภาพรวมการทำงาน

```text
ผู้ใช้กรอก Campaign No.
        ↓
กด OK
        ↓
PDTransMotCamp
        ↓
PDExportCamp
        ↓
PDpmuwd132
        ↓
กด Transfer Safe Smart
        ↓
PDTransWsvint / PDTransWsvint3
        ↓
PDSetCampaign
        ↓
PDTransSafeSmart
        ↓
Safe Smart
```

---

# ขั้นตอนการทำงานโดยละเอียด

## 1. เปิดโปรแกรม

เมื่อเปิดโปรแกรม จะเรียก

```abl
RUN enable_UI.
```

และกำหนดค่าเริ่มต้น

```abl
fi_output = "D:\temp\TrnCampYYYYMMDD.csv"
ra_campaigntype = 1
ra_grouppolicy = 1
```

ความหมาย

- Campaign Type = C (แคมเปญกลาง)
- Group Policy = All
- กำหนด Path สำหรับ Export CSV

---

## 2. กดปุ่ม OK

Event:

```abl
ON CHOOSE OF buok
```

### ตรวจสอบ Campaign No.

หากไม่ระบุ

```text
Campaign No. เป็นค่าว่าง !!!
```

### Clean Campaign Code

ลบอักขระ

- /
- -
- +
- _

เพื่อใช้สร้าง Key ID

### เรียก Process หลัก

```abl
RUN PDTransMotCamp.
```

---

## 3. PDTransMotCamp

หน้าที่หลัก

```text
stat.campaign_fil
        ↓
ctxstat.motcamp
```

### Step 3.1 Generate Date

สร้างค่า

```abl
nv_datetoday
```

ตัวอย่าง

```text
20260717
```

### Step 3.2 อ่านข้อมูล Campaign

```abl
FOR EACH stat.campaign_fil
WHERE camcod = fi_camp
```

### Step 3.3 ตรวจสอบข้อมูลซ้ำ

ค้นหาใน

```abl
ctxstat.motcamp
```

หากพบข้อมูลเดิม

```text
ไม่สามารถ Transfer ได้
ต้อง DEL ก่อน
```

### Step 3.4 Create ctxstat.motcamp

สร้างข้อมูลใหม่พร้อม Mapping Field จำนวนมาก เช่น

- camcod
- camnam
- class
- sclass
- covcod
- vehgrp
- vehuse
- baseprm
- netprm
- grossprm

### Step 3.5 Generate KeyID

```abl
keyid = nv_campaig + nv_datetoday + STRING(n_num)
```

ตัวอย่าง

```text
CAM001202607171
```

### Step 3.6 Batch Control

ทุกๆ 500 Record

```abl
n_cntkeyid = n_cntkeyid + 1
```

เพื่อแบ่งการยิง Web Service เป็นชุด

---

## 4. PDExportCamp

หน้าที่ Export ข้อมูลออก CSV

### Step 4.1 สร้าง Header

เรียก

```abl
RUN PDHeaderCamp.
```

### Step 4.2 Export Data

อ่านจาก

```abl
ctxstat.motcamp
```

และเขียนออกไฟล์ CSV

---

## 5. PDpmuwd132

หน้าที่

```text
stat.pmuwd132
        ↓
ctxstat.pmuwd132
```

กระบวนการ

1. ลบข้อมูลเดิม
2. อ่านข้อมูลจาก stat.pmuwd132
3. Create ctxstat.pmuwd132 ใหม่

---

## 6. กด Transfer Safe Smart

ปุ่ม

```abl
nv_trans_safe
```

ระบบจะแสดง Confirm Dialog

```text
ต้องการ Transfer Campaign หรือไม่
```

---

## 7. PDTransWsvint

กรณีเลือก

```text
Transfer All Policy Master
```

หน้าที่

```text
ctxstat.motcamp
        ↓
wsvint.motcamp
```

### กรณียังไม่มีข้อมูล

```abl
CREATE wsvint.motcamp
```

### กรณีมีข้อมูลเดิม

เรียก

```abl
PDTransWsvint2
```

ทำการ Delete และ Create ใหม่ทั้งหมด

---

## 8. PDTransWsvint3

ใช้สำหรับ

```text
Group Policy Master (Smiley)
```

ก่อน Create จะเช็คข้อมูลซ้ำด้วย

- camcod
- sclass
- makeyr
- simin
- simax
- mincst
- maxcst

หากซ้ำจะไม่สร้างซ้ำ

และนับจำนวน Record ที่ Transfer

```abl
n_cntcod-2
```

---

## 9. PDSetCampaign

หน้าที่

```text
Auto Create / Update Parameter Campaign
```

แทนการเข้าไปกำหนดผ่าน Motor Citrix แบบ Manual

### Logic

1. หา Running Number ล่าสุด
2. เพิ่มเลขลำดับใหม่
3. Create หรือ Update ตาราง

```abl
ctxstat.poltyp_fil
```

ข้อมูลที่จัดเก็บ

- Campaign Code
- Campaign Name
- Campaign Type
- Effective Date
- Expiry Date

---

## 10. PDTransSafeSmart

เป็นขั้นตอนส่งข้อมูลไป Safe Smart

### Step 10.1 Create WebClient

```abl
NEW System.Net.WebClient()
```

### Step 10.2 Call Web Service

```text
http://10.xx.xx.xx/styweb-online-test/tranmotcamp/?keyid=...
```

### Step 10.3 รับ Response

```abl
webResponse
```

### Step 10.4 เขียน Log

สร้างไฟล์

- PostCamp_Status.txt
- PostCamp_log.txt

เก็บ

- วันที่
- เวลา
- Campaign
- KeyID
- Response

---

## 11. Error Handling

ใช้

```abl
CATCH eAnyError
```

หาก Web Service Error

จะสร้าง Log

```text
log_eAnyError_PostCamp.txt
```

และกำหนด

```abl
ERR_Service = "error"
```

---

## 12. ปุ่ม DEL

หน้าที่ลบข้อมูล Campaign ที่เคย Transfer

ลบข้อมูลจาก

### ตารางที่ 1

```abl
ctxstat.motcamp
```

### ตารางที่ 2

```abl
ctxstat.pmuwd132
```

เพื่อให้สามารถ Transfer ใหม่ได้

---

# สรุป Business Flow

```text
1. กรอก Campaign No
2. กด OK
3. Copy stat.campaign_fil → ctxstat.motcamp
4. Export CSV
5. Copy stat.pmuwd132 → ctxstat.pmuwd132
6. กด Transfer Safe Smart
7. Copy ctxstat.motcamp → wsvint.motcamp
8. Auto Set Campaign Parameter
9. Generate KeyID
10. Call Web Service
11. Safe Smart รับข้อมูล
12. เขียน Log และ Error Log
```

## สรุป

โปรแกรมนี้เป็นเครื่องมือสำหรับ Migration และ Publish Campaign Motor ไปยังระบบ Safe Smart โดยครอบคลุมตั้งแต่การสร้างข้อมูลกลาง (ctxstat), Export ไฟล์, Sync ตาราง, สร้าง Parameter อัตโนมัติ และส่งข้อมูลผ่าน Web Service พร้อมระบบ Logging และ Error Handling ครบถ้วน
