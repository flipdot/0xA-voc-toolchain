#!/usr/bin/env python3

import xml.etree.ElementTree as ET
from pathlib import Path
import os

BASE_URL = 'http://tmp.soerface.de/4YTRGDg3MfeaWERDhVxU'
SCHEDULE_PATH = Path(os.path.realpath(__file__)).parent / 'schedule.xml'
OUTPUT_SCHEDULE_PATH = Path(os.path.realpath(__file__)).parent / 'schedule_with_video_url.xml'
TALK_MAPPING = {
    'ac2c0286-0437-5541-9808-035730daf9b1': '01_Opening',
    'b006d1fb-0e63-5841-ba5c-462fee19f1c9': '02_CUDA_Basics',
    '008f924e-42ea-5079-ac92-c4804d81c70d': '03_Die_dreckige_Empirie',
    'eb541ecf-b315-542a-93eb-bedf2d931ab2': '04_Mechanische_Zeichenmaschine',
    # 5: Not approved
    'b750a551-5c2e-59a8-b538-cce6eca1c18e': '06_Chemie_und_Physik_beim_Kochen_und_Brot_backen',
    '19078c75-46cf-59e5-ab40-07d44cdceccc': '07_Biometrische_Ueberwachung_in_Deutschland',
    'e9e9faf0-e4d6-557e-a4ba-a11d8a197ac7': '08_DargStack_Ein_Strauss_Microservices',
    '372d7e19-0f8f-56a9-92b7-27a5efb97f74': '09_Blast_Procedure_Wie_man_Party_und_Videogames_vereinen_kann',
    'e2daa1e6-0cca-58dc-a177-7988d4cf25ec': '10_Esperanto_Wie_funktioniert_eine_Plansprache',
    # 11: Not approved
    'a10e2317-83f8-5f49-a153-c73cddcb6708': '12_flipdot_Badge_design',
    'e74c38fe-641f-50d0-983b-8efe9a01d86f': '13_Closing',
}


def main():
    with open(SCHEDULE_PATH, 'r') as schedule:
        tree = ET.parse(schedule)
    root = tree.getroot()
    for room in root.iter('room'):
        not_recorded_events = []
        for event in room.iter('event'):
            guid = event.attrib['guid']
            if guid in TALK_MAPPING:
                url = '/'.join([BASE_URL, TALK_MAPPING[guid], 'output.mp4'])
                video_download_url = ET.Element('video_download_url')
                video_download_url.text = url
                event.append(video_download_url)
            else:
                not_recorded_events.append(event)
        for event in not_recorded_events:
            room.remove(event)

    tree.write(OUTPUT_SCHEDULE_PATH)


if __name__ == '__main__':
    main()
