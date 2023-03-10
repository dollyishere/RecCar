package com.heros.api.detectionInfo.entity;


import lombok.*;

import javax.persistence.*;
import javax.validation.constraints.NotNull;
import java.time.LocalDate;

@Entity
@Table(name = "DETECTION_INFO")
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class DetectionInfo {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "DETECTION_INFO_ID", columnDefinition = "INT UNSIGNED")
    private Long detectionInfoId;

    @Column(name = "PART", length = 50)
    private String part;

    @Column(name = "DAMAGE", length = 50)
    private String damage;

    @Column(name = "DAMAGE_DATE")
    private LocalDate damageDate;

    @Column(name = "MEMO")
    private String memo;

    @Column(name = "DAMAGE_IMAGE_URL")
    private String damageImageUrl;

    @Column(name = "BEFORE")
    private boolean before;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "car_id")
    private Car car;

    @Builder
    public DetectionInfo(
            @NotNull Long detectionInfoId,
            String part,
            String damage,
            LocalDate damageDate,
            String memo,
            String damageImageUrl,
            boolean before
            Car car
    ){
        this.detectionInfoId = detectionInfoId;
        this.part = part;
        this.damage = damage;
        this.damageDate = damageDate;
        this.memo = memo;
        this.damageImageUrl = damageImageUrl;
        this.before = before;
        this.car = car;
    }
}
