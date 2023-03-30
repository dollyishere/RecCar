package com.heros.api.detectionInfo.service;

import com.heros.api.car.entity.Car;
import com.heros.api.car.repository.CarRepository;
import com.heros.api.detectionInfo.dto.request.DetectionInfoCreate;
import com.heros.api.detectionInfo.dto.response.PartWithDetectionInfoResponse;
import com.heros.api.detectionInfo.dto.response.RentDetailResponse;
import com.heros.api.detectionInfo.entity.DetectionInfo;
import com.heros.api.detectionInfo.repository.DetectionInfoRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
@Slf4j
public class DetectionInfoService {

    private final DetectionInfoRepository detectionInfoRepository;
    private final CarRepository carRepository;

    public List<PartWithDetectionInfoResponse> getDetectionInfos(Long carId){
        List<PartWithDetectionInfoResponse> detectionInfos = detectionInfoRepository.getDetectionInfos(carId);
        return detectionInfos;
    }

    public RentDetailResponse getRentDetailInfos(Long carId){
        RentDetailResponse rentDetailInfos = detectionInfoRepository.getRentalDetailInfos(carId);
        return rentDetailInfos;
    }

    @Transactional
    public void createDamageInfo(List<DetectionInfoCreate> detectionInfoCreates){
        Car car = carRepository.findById(detectionInfoCreates.get(0).getCarId()).orElseThrow(IllegalArgumentException::new);
        Boolean former = detectionInfoCreates.get(0).isFormer();
        int[] damages = new int[4];
        for (DetectionInfoCreate detectionInfoCreate : detectionInfoCreates) {
            int damage = detectionInfoCreate.getScratch() + detectionInfoCreate.getBreakage() +detectionInfoCreate.getCrushed() + detectionInfoCreate.getSeparated();
            if (detectionInfoCreate.getPart().equals("front")) {
                damages[0] += damage;
            }
            else if (detectionInfoCreate.getPart().equals("side")) {
                damages[1] += damage;
            }
            else if (detectionInfoCreate.getPart().equals("back")) {
                damages[2] += damage;
            }
            else if (detectionInfoCreate.getPart().equals("wheel")) {
                damages[3] += damage;
            }
            DetectionInfo detectionInfo =  DetectionInfo.builder()
                    .car(car)
                    .former(detectionInfoCreate.isFormer())
                    .damageImageUrl(detectionInfoCreate.getPictureUrl())
                    .part(detectionInfoCreate.getPart())
                    .scratch(detectionInfoCreate.getScratch())
                    .crushed(detectionInfoCreate.getCrushed())
                    .breakage(detectionInfoCreate.getBreakage())
                    .separated(detectionInfoCreate.getSeparated())
                    .memo(detectionInfoCreate.getMemo())
                    .damageDate(detectionInfoCreate.getDamageDate())
                    .build();
            detectionInfoRepository.save(detectionInfo);
        }
        car.setDamageCount(former, damages);
    }

    public Optional<DetectionInfo> getDetectionInfoDetail(Long detectionInfoId) {
        Optional<DetectionInfo> detectionInfo = detectionInfoRepository.findById(detectionInfoId);
        return detectionInfo;
    }
}
