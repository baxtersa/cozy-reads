import Image, { StaticImageData } from "next/image";
import Container from "./container";
import { PropsWithChildren } from "react";
import React from "react";

import {
    CloudArrowDownIcon,
    DeviceTabletIcon,
    ListBulletIcon,
    PaintBrushIcon, SunIcon, TagIcon, UserGroupIcon,
  } from "@heroicons/react/24/solid";

interface FeatureData {
    title: string;
    desc: string;
    icon: React.ReactElement;
}

interface FeatureSet {
    title: string;
    desc: string;
    image: StaticImageData | undefined;
    imgPos: 'right' | 'left' | undefined;
    bullets: FeatureData[];
}

interface FeaturesProps {
    data: FeatureSet;
    imgPos: 'right' | 'left' | undefined;
}

export function Features(props: FeaturesProps) {
    const { data } = props;
    return (
        <>
            <Container className="flex flex-wrap mb-20 lg:gap-10 lg:flex-nowrap ">
                <div
                    className={`flex items-center justify-center w-full lg:w-1/2 ${props.imgPos === "right" ? "lg:order-1" : ""
                        }`}>
                    <div>
                        {data.image !== undefined ?
                            <Image
                                src={data.image}
                                width="521"
                                // height="auto"
                                alt="Benefits"
                                className={"object-cover"}
                                placeholder="blur"
                                blurDataURL={data.image.src}
                            /> :
                            <></>
                        }
                    </div>
                </div>

                <div
                    className={`flex flex-wrap items-center w-full lg:w-1/2 ${data.imgPos === "right" ? "lg:justify-end" : ""
                        }`}>
                    <div>
                        <div className="flex flex-col w-full mt-4">
                            <h3 className="max-w-2xl mt-3 text-3xl font-bold leading-snug tracking-tight text-gray-800 lg:leading-tight lg:text-4xl dark:text-white">
                                {data.title}
                            </h3>

                            <p className="max-w-2xl py-4 text-lg leading-normal text-gray-500 lg:text-xl xl:text-xl dark:text-gray-300">
                                {data.desc}
                            </p>
                        </div>

                        <div className="w-full mt-5">
                            {data.bullets.map((item, index) => (
                                <Feature key={index} title={item.title} icon={item.icon}>
                                    {item.desc}
                                </Feature>
                            ))}
                        </div>
                    </div>
                </div>
            </Container>
        </>
    );
}

function Feature(props: PropsWithChildren<Omit<FeatureData, 'desc'>>) {
    return (
        <div>
            <div className="flex items-start mt-8 space-x-3">
                <div className="flex items-center justify-center flex-shrink-0 mt-1 bg-gradientDark rounded-md w-11 h-11 ">
                    {React.cloneElement(props.icon, {
                        className: "w-7 h-7 text-gray-50",
                    })}
                </div>
                <div>
                    <h4 className="text-xl font-medium text-gray-800 dark:text-gray-200">
                        {props.title}
                    </h4>
                    <p className="mt-1 text-gray-500 dark:text-gray-400">
                        {props.children}
                    </p>
                </div>
            </div>
        </div>
    )
}

export const featureDevices: FeatureSet = {
    title: "Track your reading habits",
    desc: "CozyReads focuses on helping you get more enjoyment out of reading.",
    image: undefined,
    imgPos: undefined,
    bullets: [
        {
            title: "Categorize your books",
            desc: "Filter lists by genre, author, series, and more",
            icon: <ListBulletIcon />
        },
        {
            title: "Sync across all of your devices",
            desc: "Sign into your Apple iCloud account to add books from your iPhone and mark them as finished from your iPad or Mac device",
            icon: <CloudArrowDownIcon />
        }
    ]
}

export const featureOne: FeatureSet = {
    title: "Visualize your reading preferences",
    desc: "Customize graphs, metadata, and appearance in whatever way makes sense to you.",
    image: undefined,
    imgPos: undefined,
    bullets: [
        {
            title: "Custom Tags",
            desc: "Tag books with custom metadata",
            icon: <TagIcon />,
        },
        {
            title: "Dark & Light Mode",
            desc: "CozyReads supports dark and light modes to suit your style",
            icon: <SunIcon />,
        },
    ],
};

export const featureIAP: FeatureSet = {
    title: "Unlock additional features with In-App Purchases",
    desc: "CozyReads is provided as a free service, but In-App Purchases allow you to expand your book tracking experience in additional ways.",
    image: undefined,
    imgPos: undefined,
    bullets: [
        {
            title: "Multiple Color Schemes",
            desc: "Change the app's theme depending on your vibes",
            icon: <PaintBrushIcon />
        },
        {
            title: "Multiple Profiles",
            desc: "Track multiple users' reading habits separately from the same device",
            icon: <UserGroupIcon />
        }
    ]
}