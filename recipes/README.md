# 制作時のレシピ

- [Sequencer8x1](Sequencer8x1): 8ステップ1パートのシーケンサ
- [Sequencer4x2](Sequencer4x2): 4ステップ2パートのシーケンサ
- [Jaikenzan](Jaikenzan): じゃいけんざん
- [EuclidRhythmSender](EuclidRhythmSender): ユークリッドのリズム

## シーケンサーのフローチャート

```mermaid
flowchart
    classDef ta-left text-center: left;

    subgraph setup["setup()"]
        initCs["現在のステップを0にする
            int currentStep = 0;"]
        initStep["すべてのステップを非アクティブにする
            for (int i = 0; i < steps.length; i++) { steps[i] = false; }"]
    end
    subgraph draw["draw()"]
        loopStart[drawループの先頭]
        subgraph ステップ制御処理
            incStep["ステップを一つ進める
                currentStep++;"]
            ifCsOver{"もし現在のステップが範囲外なら
                if (currentStep >= steps.length)"}:::ta-center
            resetCs["ステップを0にする
                currentStep = 0;"]
        end
        subgraph OSCの送信処理
            ifStepTrue{"もし現在のステップがアクティブなら
                if (steps[currentStep])"}:::ta-center
            sendOsc["OSCを送信
                OscMessage message = new OscMessage(/bang);
                oscP5.send(message, addresses[currentStep]);
                println(addresses[currentStep], message);"]
        end
    end

    initCs --> initStep
    initStep --> loopStart

    loopStart --> incStep
    incStep --> ifCsOver
    ifCsOver -->|true| resetCs --> ifStepTrue
    ifCsOver -->|false| ifStepTrue
    ifStepTrue --> |true| sendOsc --> loopStart
    ifStepTrue --> |false| loopStart
```
