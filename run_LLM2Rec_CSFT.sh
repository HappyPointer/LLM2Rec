# First stage of LLM2Rec training -- Collaborative Supervised Fine-Tuning (CSFT).

model_path="/home/yingzhi/huggingface_data/hub/Qwen2-0.5B"  # Replace with your own model path

for category in "AmazonMix-6"
do
    train_file=$(ls -f ./data/${category}/5-core/train/${category}*.csv)
    eval_file=$(ls -f ./data/${category}/5-core/valid/${category}*.csv)
    echo ${train_file} ${info_file}

    CUDA_VISIBLE_DEVICES=0,1 torchrun --master_port=25649 --nproc_per_node 2 \
        ./llm2rec/run_csft.py \
        --base_model ${model_path} \
        --train_file ${train_file} \
        --eval_file ${eval_file} \
        --output_dir ./output/Qwen2-0.5B-CSFT-${category} \
        --wandb_run_name Qwen2-0.5B-CSFT-${category} \
        --category ${category} \
        --train_from_scratch False \
        --use_lora False

    cp ${model_path}/*token* ./output/Qwen2-0.5B-CSFT-${category}/
    # Also copy tokenizer to the last checkpoint
    latest_ckpt=$(ls -d ./output/Qwen2-0.5B-CSFT-${category}/checkpoint-* | sort -V | tail -n 1)
    cp ${model_path}/*token* ${latest_ckpt}/
done



# echo "Starting Stage 2 - Train MNTP..."
# cp /home/yingzhi/huggingface_data/hub/gemma-2b/*token* ./output/gemma-2b-FULL-Amazon6-wo-prompt-SFT-AmazonMix-6/checkpoint-10000/
# CUDA_VISIBLE_DEVICES=4,5 torchrun --nproc_per_node=2 --master_port=29501 ./llm2rec/run_mntp.py ./llm2rec/Rebuttal_train_mntp_config.json

# # Stage 3 - Train SimCSE
# echo "Starting Stage 3 - Train SimCSE..."
# cp /home/yingzhi/huggingface_data/hub/gemma-2b/*token* ./output/mntp/gemma-2b-FULL-SFT-AmazonMix-6/checkpoint-1000/
# CUDA_VISIBLE_DEVICES=4,5 torchrun --nproc_per_node=2 --master_port=29502 run_unsupervised_SimCSE.py ./llm2rec/Rebuttal_train_simcse_config.json
